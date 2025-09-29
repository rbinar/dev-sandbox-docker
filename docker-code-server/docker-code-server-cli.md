```bash
docker rm -f code-server 2>/dev/null || true
docker volume create code_server_config
docker run -d \
  --name=code-server \
  -e PUID=1000 -e PGID=1000 -e TZ=Europe/Istanbul \
  -e PASSWORD='şuraya-şifre' \
  -p 8443:8443 \
  -v code_server_config:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/code-server:latest
```