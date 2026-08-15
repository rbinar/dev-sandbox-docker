# 🧰 AI Harness Sandbox - Manual CLI Commands

### Container Management

```bash
# Başlat (ilk derleme birkaç dakika sürer)
cd sandbox-harness
docker-compose up -d --build

# Container durumunu kontrol et
docker ps | grep sandbox-harness

# Loglara bak
docker logs sandbox-harness
docker logs -f sandbox-harness   # real-time takip

# Durdur (veriler korunur)
docker-compose stop

# Yeniden başlat
docker-compose restart

# Değişiklikten sonra yeniden derle
docker-compose up -d --build

# Container'ı ve volume'leri sil (TAM SIFIRLAMA — login bilgileri de gider)
docker-compose down -v
```

### Container İçine Shell Açma

```bash
# Genel amaçlı shell (dev kullanıcısı olarak)
docker exec -it sandbox-harness bash
```

### Tek Bir Harness'ı Elle Çalıştırma

Picker'ı hiç açmadan, doğrudan container içinden bir harness'ı çalıştırmak için:

```bash
docker exec -it sandbox-harness bash -lc claude
docker exec -it sandbox-harness bash -lc codex
docker exec -it sandbox-harness bash -lc agy
docker exec -it sandbox-harness bash -lc opencode
docker exec -it sandbox-harness bash -lc copilot
```

Bu yol, ilgili harness'ın web terminaline (`launch.sh`) hiç dokunmaz — login/kurulum
kontrolü ve çıkış sonrası kabuğa düşme davranışı yalnızca web terminalinde vardır.

### Hangi Harness'ların Kurulu Olduğunu Görme

```bash
# Picker'ın kendi status API'si (container ayaktayken)
curl -s localhost:3060/api/status | jq

# Ya da container içinden PATH kontrolü
docker exec sandbox-harness bash -lc 'for c in claude codex agy opencode copilot; do command -v "$c" >/dev/null 2>&1 && echo "$c: kurulu" || echo "$c: KURULU DEGIL"; done'
```

### Volume Yönetimi

```bash
# Bu sandbox'ın volume'lerini listele
docker volume ls | grep sandbox-harness

# harness-home içeriğine bak (login bilgileri, ayarlar)
docker exec sandbox-harness ls -la /home/dev

# harness-work içeriğine bak (üzerinde çalışılan dosyalar)
docker exec sandbox-harness ls -la /home/dev/work

# Sadece workspace'i sıfırla, login bilgilerini koru
docker-compose stop
docker volume rm sandbox-harness_harness-work
docker-compose up -d

# Sadece login bilgilerini sıfırla (tüm harness'lara yeniden login gerekir), workspace'i koru
docker-compose stop
docker volume rm sandbox-harness_harness-home
docker-compose up -d

# İkisini de sil (TAM SIFIRLAMA)
docker-compose down -v
```

### Port Çakışması Olursa

`3060`-`3065` arası portlardan biri host'ta zaten kullanımdaysa `docker-compose up`
hata verir. Çözüm: `docker-compose.yml`'deki `ports:` bloğunda çakışan satırın host
tarafını değiştir (container tarafına dokunma — `serve.mjs` ve `launch.sh` içindeki
port numaralarıyla eşleşmesi gerekir):

```yaml
ports:
  - "127.0.0.1:13060:3060"   # örn. 3060 doluysa host tarafını değiştir
```

Değişiklikten sonra:

```bash
docker-compose up -d
```

Hangi sürecin portu tuttuğunu bulmak için:

```bash
lsof -i :3060       # macOS/Linux
```

### Troubleshooting

```bash
# Container ayakta mı, restart döngüsünde mi?
docker ps -a | grep sandbox-harness

# tini/entrypoint çıktısını gör
docker logs sandbox-harness

# Bir harness terminali hiç açılmıyorsa: container içinden ttyd süreçlerine bak
docker exec sandbox-harness ps aux | grep ttyd

# Kaynak kullanımı (mem_limit: 4g, cpus: 2.0 ile sınırlı)
docker stats sandbox-harness
```

## Kaynaklar

- [ttyd](https://github.com/tsl0922/ttyd)
- [Claude Code](https://github.com/anthropics/claude-code)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [OpenCode](https://opencode.ai/)
- [GitHub Copilot CLI](https://github.com/github/copilot-cli)
