package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type CustomHandler struct{}

func (h *CustomHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.URL.Path {
	case "/":
		h.handleRoot(w, r)
	case "/calculate":
		h.handleCalculate(w, r)
	default:
		http.NotFound(w, r)
	}
}

func (h *CustomHandler) handleRoot(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]string{"message": "Welcome to HTTPServer!"}
	json.NewEncoder(w).Encode(response)
}

func (h *CustomHandler) handleCalculate(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	result := h.calculate()
	response := map[string]int{"result": result}
	json.NewEncoder(w).Encode(response)
}

func (h *CustomHandler) calculate() int {
	// 模拟复杂的计算操作
	time.Sleep(100 * time.Millisecond) // 模拟耗时操作
	return 42
}

func main() {
	server := &http.Server{
		Addr:    ":8000",
		Handler: &CustomHandler{},
	}
	fmt.Println("Starting HTTPServer on port 8000...")
	err := server.ListenAndServe()
	if err != nil {
		fmt.Printf("Error starting server: %v\n", err)
	}
}

/*
ab -n 100 -c 50 http://127.0.0.1:8000/calculate
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient).....done


Server Software:
Server Hostname:        127.0.0.1
Server Port:            8000

Document Path:          /calculate
Document Length:        14 bytes

Concurrency Level:      50
Time taken for tests:   0.328 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      12200 bytes
HTML transferred:       1400 bytes
Requests per second:    304.66 [#/sec] (mean)
Time per request:       164.118 [ms] (mean)
Time per request:       3.282 [ms] (mean, across all concurrent requests)
Transfer rate:          36.30 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    6   1.8      6       9
Processing:   100  104   2.8    104     110
Waiting:      100  103   2.2    102     110
Total:        104  110   2.7    111     118

Percentage of the requests served within a certain time (ms)
  50%    111
  66%    112
  75%    112
  80%    112
  90%    113
  95%    113
  98%    115
  99%    118
 100%    118 (longest request)

*/
