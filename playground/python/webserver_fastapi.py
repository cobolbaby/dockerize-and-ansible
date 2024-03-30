from fastapi import FastAPI
import uvicorn
import json
import time

app = FastAPI()

@app.get("/")
async def index():
    return {"message": "Welcome to FastAPI!"}

@app.get("/calculate")
async def calculate():
    # 模拟复杂的计算操作
    time.sleep(0.1)  # 模拟耗时操作
    return {"result": 42}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)

'''
ab -n 100 -c 50 http://127.0.0.1:8001/calculate
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient).....done


Server Software:        uvicorn
Server Hostname:        127.0.0.1
Server Port:            8001

Document Path:          /calculate
Document Length:        13 bytes

Concurrency Level:      50
Time taken for tests:   10.275 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      15700 bytes
HTML transferred:       1300 bytes
Requests per second:    9.73 [#/sec] (mean)
Time per request:       5137.583 [ms] (mean)
Time per request:       102.752 [ms] (mean, across all concurrent requests)
Transfer rate:          1.49 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    2   1.0      2       4
Processing:   108 4493 1583.0   5130    7797
Waiting:      103 3334 1424.5   3700    5143
Total:        108 4495 1582.5   5130    7798

Percentage of the requests served within a certain time (ms)
  50%   5130
  66%   5133
  75%   5134
  80%   5139
  90%   5140
  95%   7797
  98%   7798
  99%   7798
 100%   7798 (longest request)
'''