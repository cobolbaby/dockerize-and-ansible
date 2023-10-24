#!/bin/bash

for line in $(cat domain.txt)
do
    domain=$(echo ${line} | awk -F':' '{print $1}')
    ip_pool=$(echo ${line} | awk -F '[a-z]:' '{print $2}' | sed 's/\,/ /g')
    for ip in ${ip_pool}
    do
        echo -e "\e[33m---------------start to check---------------\e[0m"
        echo -e "ip：${ip}\ndomain：${domain}"
        
        text=$(echo | openssl s_client -servername ${domain} -connect ${ip}:443 2>/dev/null | openssl x509 -noout -dates )
        # 判断命令是否执行成功,执行成功的话 text 变量里面是有内容的
        if [[ ${text} ]]
        then
            end_date=$(echo "$text" | grep -i "notAfter" | awk -F '=' '{print $2}') # 证书过期时间
            end_timestamp=$(date -d "$end_date" +%s) # 转换成时间戳
            
            current_timestamp=$(date +%s) # 当前时间戳
            
            # 如果证书过期时间减去当前时间的天数小于七天的话，则提示需要准备更换证书了
            remain_date=$(( (${end_timestamp} - ${current_timestamp}) / 86400 ))
            if [[ ${remain_date} -lt 7 && ${remain_date} -ge 0 ]]
            then
                echo -e "\e[31m剩余时间小于七天！请及时更换证书！\e[0m"
                echo -e "\e[31mip: ${ip}, ${domain}\e[0m"
            elif [[ ${remain_date} -lt 0 ]]
            then
                echo -e "\e[31m证书已过期！请及时更换证书！\e[0m"
            else
                echo -e "\e[32m剩余天数为：${remain_date}\e[0m"
            fi
        else
            echo -e "\e[31mError!${ip}\e[0m"
            echo -e "\e[31m${domain}\e[0m"
        fi
    done
done
