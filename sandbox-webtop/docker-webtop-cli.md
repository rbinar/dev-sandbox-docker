````markdown
```bash
docker rm -f sandbox-webtop 2>/dev/null || true
docker volume create webtop_config
docker run -d \
  --name=sandbox-webtop \
  -e PUID=1000 -e PGID=1000 -e TZ=Europe/Istanbul \
  -e SUBFOLDER=/ -e KEYBOARD=tr-tr-qwerty \
  -p 3010:3000 -p 3011:3001 \
  -v webtop_config:/config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --shm-size=2g \
  --restart unless-stopped \
  lscr.io/linuxserver/webtop:latest
```
````