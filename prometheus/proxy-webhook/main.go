package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync/atomic"
)

var (
	targets    []*url.URL
	counter    uint64
	listenPort string
)

type multiFlag []string

func (m *multiFlag) String() string { return fmt.Sprintf("%v", *m) }
func (m *multiFlag) Set(value string) error {
	*m = append(*m, value)
	return nil
}

func parseFlags() {
	var targetList multiFlag
	flag.Var(&targetList, "target", "下游目标地址（可配置多个）")
	flag.StringVar(&listenPort, "port", "8080", "监听端口")

	flag.Parse()

	for _, raw := range targetList {
		parsed, err := url.Parse(raw)
		if err != nil {
			log.Printf("无效的目标地址：%s，已跳过", raw)
			continue
		}
		targets = append(targets, parsed)
	}

	if len(targets) == 0 {
		log.Println("未配置下游目标地址，将仅打印请求，不转发")
	}
}

func printRequest(r *http.Request) {
	dump, err := httputil.DumpRequest(r, true)
	if err != nil {
		log.Println("请求打印失败:", err)
		return
	}
	log.Println("======= HTTP 请求开始 =======")
	log.Println(string(dump))
	log.Println("======= HTTP 请求结束 =======")
}

func getNextTarget() *url.URL {
	if len(targets) == 0 {
		return nil
	}
	// 轮询策略
	i := atomic.AddUint64(&counter, 1)
	return targets[int(i)%len(targets)]
}

func handleProxy(w http.ResponseWriter, r *http.Request) {
	printRequest(r)

	target := getNextTarget()
	if target == nil {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("未配置下游地址，仅打印请求\n"))
		return
	}

	proxyURL := target.ResolveReference(r.URL)

	proxyReq, err := http.NewRequest(r.Method, proxyURL.String(), r.Body)
	if err != nil {
		http.Error(w, "构造请求失败", http.StatusInternalServerError)
		return
	}

	// 复制请求头
	proxyReq.Header = r.Header.Clone()

	client := &http.Client{}
	resp, err := client.Do(proxyReq)
	if err != nil {
		http.Error(w, "下游请求失败："+err.Error(), http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	// 设置响应头
	for k, vv := range resp.Header {
		for _, v := range vv {
			w.Header().Add(k, v)
		}
	}

	// 写入状态码 + 响应体
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

func main() {
	parseFlags()

	http.HandleFunc("/", handleProxy)
	log.Printf("代理服务启动，监听端口: %s\n", listenPort)
	log.Fatal(http.ListenAndServe(":"+listenPort, nil))
}
