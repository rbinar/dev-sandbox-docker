## Docker-Chromium Konteynerini Başlatma

Terminalde `docker-chromium-cli.md` içindeki komutları çalıştırarak docker-chromium konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Her iki durumda da, konteyner başlatıldıktan sonra [`https://localhost:3001`](https://localhost:3001) adresinden Chromium tarayıcısına erişebilirsiniz. (SSL sertifikası nedeniyle tarayıcıda bir güvenlik uyarısı alabilirsiniz. Bu normaldir ve güvenlik uyarısını geçebilirsiniz. Zaten işlem sonrası konteyneri silip yeniden oluşturacaksınız.)

## Kaynaklar

- [LinuxServer.io - linuxserver/chromium](https://docs.linuxserver.io/images/docker-chromium/)