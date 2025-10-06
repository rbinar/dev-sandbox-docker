## Docker-Webtop Konteynerini Başlatma

Terminalde `docker-webtop-cli.md` içindeki komutları çalıştırarak docker-webtop konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Her iki durumda da, konteyner başlatıldıktan sonra [`http://localhost:3010`](http://localhost:3010) adresinden Webtop Linux Desktop'a erişebilirsiniz.

### 🦠 **ClamAV Virüs Tarayıcısı Entegrasyonu**

**Setup script ile kurulum yaparsan, ClamAV virüs tarayıcısı otomatik olarak kurulur!**

#### Manuel ClamAV Kurulumu:
```bash
# Container içine gir
docker exec -it sandbox-webtop sh

# ClamAV kur
apk update && apk add clamav clamav-daemon freshclam

# Virus database güncelle
freshclam

# Test taraması
clamscan --version
```

#### ClamAV Kullanım Örnekleri:
```bash
# Tek dosya tara
clamscan /path/to/file

# Dizin taraması  
clamscan -r /home/abc/Downloads/

# Detaylı log
clamscan -v --log=/tmp/scan.log /downloads/

# Test virus dosyası ile test
wget https://secure.eicar.org/eicar.com.txt
clamscan eicar.com.txt
```

### Güvenlik Kullanım Senaryoları

- **Şüpheli dosya analizi**: Bilinmeyen dosyaları izole Linux ortamında açma
- **Güvenilmeyen yazılım testi**: Linux uygulamalarını ana sistem riske atmadan test etme
- **Geliştirme ortamı izolasyonu**: Farklı development stack'lerini ayrı tutma
- **Network testleri**: İzole ağ ortamında güvenlik testleri

## Kaynaklar

- [LinuxServer.io - linuxserver/webtop](https://docs.linuxserver.io/images/docker-webtop/)