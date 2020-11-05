import sys

import request

if __name__ == "__main__":
    print(sys.argv)

    # 先获取需要用到的参数
    # 将获取到的参数转化成字典

    # 拼接一个Json
    payload = {

    }

    # 发送HTTP请求
    res = request.post(
        'https://httpbin.org/post',
        json = payload,
    )
    print(res.json())

