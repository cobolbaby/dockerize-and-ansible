```bash
docker run -d -v /tmp/ftp:/home/vsftpd \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e FTP_USER=ftp027 -e FTP_PASS=ftp027 \
-e PASV_ADDRESS=10.190.5.13 \
-e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd  fauria/vsftpd

docker run -d \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e FTP_USER=myuser -e FTP_PASS=mypass \
-e PASV_ADDRESS=10.190.254.56 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd fauria/vsftpd
```
