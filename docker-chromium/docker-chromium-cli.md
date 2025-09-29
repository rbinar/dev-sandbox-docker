```bash
docker run -d \
  --name chromium \
  -p 3000:3000 -p 3001:3001 \
  -e PUID=1000 -e PGID=1000 -e TZ=Europe/Istanbul \
  -v chromium_config:/config \
  --shm-size=2g \
  --restart unless-stopped \
  lscr.io/linuxserver/chromium:5f5dd27e-ls102
```