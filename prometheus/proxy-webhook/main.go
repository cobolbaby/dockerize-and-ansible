package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"sync"
	"sync/atomic"
	"time"

	"github.com/prometheus/alertmanager/template"
	"github.com/prometheus/common/model"
)

type FingerprintStore struct {
	mu    sync.RWMutex
	store map[model.Fingerprint]time.Time
}

func NewFingerprintStore() *FingerprintStore {
	return &FingerprintStore{
		store: make(map[model.Fingerprint]time.Time),
	}
}

func (s *FingerprintStore) Get(fp model.Fingerprint) (time.Time, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	t, ok := s.store[fp]
	return t, ok
}

func (s *FingerprintStore) SetIfAbsent(fp model.Fingerprint, t time.Time) time.Time {
	s.mu.Lock()
	defer s.mu.Unlock()
	if existing, ok := s.store[fp]; ok {
		return existing
	}
	s.store[fp] = t
	return t
}

func (s *FingerprintStore) Delete(fp model.Fingerprint) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.store, fp)
}

var (
	targets    []*url.URL
	counter    uint64
	listenPort string
	store      *FingerprintStore = NewFingerprintStore()
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

	/*
	   2025/05/28 10:28:53 ======= HTTP 请求开始 =======
	   2025/05/28 10:28:53 POST / HTTP/1.1
	   Host: 192.168.2.17:9094
	   Content-Length: 953
	   Content-Type: application/json
	   User-Agent: Alertmanager/0.24.0

	   {"receiver":"wechat","status":"firing","alerts":[{"status":"firing","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"yellow"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 120 seconds.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:28:23.089Z","endsAt":"0001-01-01T00:00:00Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"a8c518a872e3149a"}],"groupLabels":{"instance":"10.3.205.79:9100"},"commonLabels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"yellow"},"commonAnnotations":{"description":"10.3.205.79:9100 of job host has been down for more than 120 seconds.","summary":"Instance 10.3.205.79:9100 down"},"externalURL":"http://alertmanager:9093","version":"4","groupKey":"{}/{job=~\"dcagent|host\"}:{instance=\"10.3.205.79:9100\"}","truncatedAlerts":0}

	   2025/05/28 10:28:53 ======= HTTP 请求结束 =======


	   2025/05/28 10:32:53 ======= HTTP 请求结束 =======
	   2025/05/28 10:36:53 ======= HTTP 请求开始 =======
	   2025/05/28 10:36:53 POST / HTTP/1.1
	   Host: 192.168.2.17:9094
	   Content-Length: 951
	   Content-Type: application/json
	   User-Agent: Alertmanager/0.24.0

	   {"receiver":"wechat","status":"firing","alerts":[{"status":"firing","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"orange"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 10 minutes.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:36:23.089Z","endsAt":"0001-01-01T00:00:00Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"6a95ebcc150ee0f4"}],"groupLabels":{"instance":"10.3.205.79:9100"},"commonLabels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"orange"},"commonAnnotations":{"description":"10.3.205.79:9100 of job host has been down for more than 10 minutes.","summary":"Instance 10.3.205.79:9100 down"},"externalURL":"http://alertmanager:9093","version":"4","groupKey":"{}/{job=~\"dcagent|host\"}:{instance=\"10.3.205.79:9100\"}","truncatedAlerts":0}

	   2025/05/28 10:36:53 ======= HTTP 请求结束 =======


	   2025/05/28 10:56:53 ======= HTTP 请求开始 =======
	   2025/05/28 10:56:53 POST / HTTP/1.1
	   Host: 192.168.2.17:9094
	   Content-Length: 945
	   Content-Type: application/json
	   User-Agent: Alertmanager/0.24.0

	   {"receiver":"wechat","status":"firing","alerts":[{"status":"firing","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"red"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 30 minutes.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:56:23.089Z","endsAt":"0001-01-01T00:00:00Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"8b581f60e6fd0de1"}],"groupLabels":{"instance":"10.3.205.79:9100"},"commonLabels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"red"},"commonAnnotations":{"description":"10.3.205.79:9100 of job host has been down for more than 30 minutes.","summary":"Instance 10.3.205.79:9100 down"},"externalURL":"http://alertmanager:9093","version":"4","groupKey":"{}/{job=~\"dcagent|host\"}:{instance=\"10.3.205.79:9100\"}","truncatedAlerts":0}

	   2025/05/28 10:56:53 ======= HTTP 请求结束 =======
	   2025/05/28 11:56:53 ======= HTTP 请求开始 =======
	   2025/05/28 11:56:53 POST / HTTP/1.1
	   Host: 192.168.2.17:9094
	   Content-Length: 945
	   Content-Type: application/json
	   User-Agent: Alertmanager/0.24.0

	   {"receiver":"wechat","status":"firing","alerts":[{"status":"firing","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"red"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 30 minutes.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:56:23.089Z","endsAt":"0001-01-01T00:00:00Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"8b581f60e6fd0de1"}],"groupLabels":{"instance":"10.3.205.79:9100"},"commonLabels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"red"},"commonAnnotations":{"description":"10.3.205.79:9100 of job host has been down for more than 30 minutes.","summary":"Instance 10.3.205.79:9100 down"},"externalURL":"http://alertmanager:9093","version":"4","groupKey":"{}/{job=~\"dcagent|host\"}:{instance=\"10.3.205.79:9100\"}","truncatedAlerts":0}

	   2025/05/28 12:26:53 ======= HTTP 请求开始 =======
	   2025/05/28 12:26:53 POST / HTTP/1.1
	   Host: 192.168.2.17:9094
	   Content-Length: 1762
	   Content-Type: application/json
	   User-Agent: Alertmanager/0.24.0

	   {"receiver":"wechat","status":"resolved","alerts":[{"status":"resolved","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"orange"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 10 minutes.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:36:23.089Z","endsAt":"2025-05-28T04:26:23.089Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"6a95ebcc150ee0f4"},{"status":"resolved","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"red"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 30 minutes.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:56:23.089Z","endsAt":"2025-05-28T04:26:23.089Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"8b581f60e6fd0de1"},{"status":"resolved","labels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host","severity":"yellow"},"annotations":{"description":"10.3.205.79:9100 of job host has been down for more than 120 seconds.","summary":"Instance 10.3.205.79:9100 down"},"startsAt":"2025-05-28T02:28:23.089Z","endsAt":"2025-05-28T04:26:23.089Z","generatorURL":"http://prometheus:9090/graph?g0.expr=up+%3D%3D+0\u0026g0.tab=1","fingerprint":"a8c518a872e3149a"}],"groupLabels":{"instance":"10.3.205.79:9100"},"commonLabels":{"alertname":"instance-down","instance":"10.3.205.79:9100","job":"host"},"commonAnnotations":{"summary":"Instance 10.3.205.79:9100 down"},"externalURL":"http://alertmanager:9093","version":"4","groupKey":"{}/{job=~\"dcagent|host\"}:{instance=\"10.3.205.79:9100\"}","truncatedAlerts":0}
	*/

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "读取请求体失败", http.StatusBadRequest)
		return
	}
	r.Body.Close()

	// 解析 JSON 为 template.Data
	var data template.Data
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		http.Error(w, "解析 JSON 失败："+err.Error(), http.StatusBadRequest)
		return
	}

	// 计算 fingerprint，保持 startsAt
	for i := range data.Alerts {
		alert := &data.Alerts[i]

		// 将 Labels 转为 model.LabelSet，但排除 severity
		ls := model.LabelSet{}
		for k, v := range alert.Labels {
			if k == "severity" {
				continue
			}
			ls[model.LabelName(k)] = model.LabelValue(v)
		}

		// 篡改 Fingerprint
		fp := ls.Fingerprint()
		alert.Fingerprint = fp.String()

		if model.AlertStatus(alert.Status) == model.AlertResolved {
			store.Delete(fp)
		} else {
			// 修正 StartsAt
			alert.StartsAt = store.SetIfAbsent(fp, alert.StartsAt)
		}

	}

	// 重编码
	newBody, err := json.Marshal(data)
	if err != nil {
		http.Error(w, "重新编码请求体失败", http.StatusInternalServerError)
		return
	}

	proxyReq, err := http.NewRequest(r.Method, proxyURL.String(), bytes.NewBuffer(newBody))
	if err != nil {
		http.Error(w, "构造请求失败", http.StatusInternalServerError)
		return
	}
	proxyReq.Header = r.Header.Clone()

	printRequest(proxyReq)

	client := &http.Client{}
	resp, err := client.Do(proxyReq)
	if err != nil {
		http.Error(w, "下游请求失败："+err.Error(), http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()

	for k, vv := range resp.Header {
		for _, v := range vv {
			w.Header().Add(k, v)
		}
	}
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}
func main() {
	parseFlags()

	http.HandleFunc("/", handleProxy)
	log.Printf("代理服务启动，监听端口: %s\n", listenPort)
	log.Fatal(http.ListenAndServe(":"+listenPort, nil))
}
