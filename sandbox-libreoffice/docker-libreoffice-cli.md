````markdown
```bash
docker rm -f sandbox-libreoffice 2>/dev/null || true
docker volume create libreoffice_config
docker run -d \
  --name=sandbox-libreoffice \
  -e PUID=1000 -e PGID=1000 -e TZ=Europe/Istanbul \
  -p 3020:3000 -p 3021:3001 \
  -v libreoffice_config:/config \
  --shm-size=1g \
  --restart unless-stopped \
  lscr.io/linuxserver/libreoffice:latest
```
````