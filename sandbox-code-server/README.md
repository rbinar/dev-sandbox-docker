## Docker-Code-Server Konteynerini Başlatma

Terminalde `docker-code-server-cli.md` içindeki komutları çalıştırarak docker-code-server konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Her iki durumda da, konteyner başlatıldıktan sonra [`http://localhost:8443`](http://localhost:8443) adresinden Code-Server'a erişebilirsiniz.

**Not:** Giriş yaparken `docker-compose.yml` dosyasında belirttiğiniz PASSWORD değerini kullanmanız gerekiyor.

## Kaynaklar

- [LinuxServer.io - linuxserver/code-server](https://docs.linuxserver.io/images/docker-code-server/)