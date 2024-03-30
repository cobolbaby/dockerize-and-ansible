from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import time

class CustomHTTPRequestHandler(BaseHTTPRequestHandler):
    def _set_response(self, status_code=200):
        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        if self.path == '/':
            self._set_response()
            response = {'message': 'Welcome to HTTPServer!'}
            self.wfile.write(json.dumps(response).encode('utf-8'))
        elif self.path == '/calculate':
            self._set_response()
            result = self._calculate()
            response = {'result': result}
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self._set_response(404)
            response = {'error': 'Not Found'}
            self.wfile.write(json.dumps(response).encode('utf-8'))

    def _calculate(self):
        # 模拟复杂的计算操作
        time.sleep(0.1)  # 模拟耗时操作
        return 42

def run(server_class=HTTPServer, handler_class=CustomHTTPRequestHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting HTTPServer on port {port}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()

'''
ab -n 100 -c 50 http://127.0.0.1:8000/calculate
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient).....done


Server Software:        BaseHTTP/0.6
Server Hostname:        127.0.0.1
Server Port:            8000

Document Path:          /calculate
Document Length:        14 bytes

Concurrency Level:      50
Time taken for tests:   10.160 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      13800 bytes
HTML transferred:       1400 bytes
Requests per second:    9.84 [#/sec] (mean)
Time per request:       5079.828 [ms] (mean)
Time per request:       101.597 [ms] (mean, across all concurrent requests)
Transfer rate:          1.33 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.3      0       1
Processing:   101  689  95.3    711     713
Waiting:        1  589  95.3    610     612
Total:        101  690  95.1    711     713

Percentage of the requests served within a certain time (ms)
  50%    711
  66%    711
  75%    712
  80%    712
  90%    712
  95%    713
  98%    713
  99%    713
 100%    713 (longest request)
'''