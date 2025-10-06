## Docker-LibreOffice Konteynerini Başlatma

Terminalde `docker-libreoffice-cli.md` içindeki komutları çalıştırarak docker-libreoffice konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Her iki durumda da, konteyner başlatıldıktan sonra [`http://localhost:3020`](http://localhost:3020) adresinden LibreOffice'e erişebilirsiniz.

### Güvenlik Kullanım Senaryoları

- **Şüpheli Office dosyaları**: .docx, .xlsx, .pptx dosyalarını güvenle açma
- **Macro virüs koruması**: Zararlı makro içerebilecek dosyaları izole ortamda inceleme
- **PDF güvenliği**: Şüpheli PDF dosyalarını ana sistemi riske atmadan görüntüleme
- **Format analizi**: Bilinmeyen dosya formatlarını güvenle test etme

## Kaynaklar

- [LinuxServer.io - linuxserver/libreoffice](https://docs.linuxserver.io/images/docker-libreoffice/)