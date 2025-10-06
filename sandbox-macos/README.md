# macOS Sandbox

**macOS container** - Apple'ın macOS işletim sistemini Docker container'ı içinde çalıştırmak için güvenli sandbox ortamı.

## 🚀 Hızlı Başlatma

```bash
cd sandbox-macos
docker-compose up -d
```

## 🌐 Erişim

- **Web Interface**: http://localhost:3050
- **VNC**: localhost:3051

## ⚡ Özellikler

- **macOS 14 Sonoma** (varsayılan)
- **4GB RAM, 2 CPU çekirdeği**
- **64GB sanal disk**
- **Web tabanlı erişim**
- **VNC desteği**
- **Veri persistence**

## 🔧 Yapılandırma

Docker Compose dosyasında değiştirebileceğiniz önemli ayarlar:

```yaml
environment:
  - VERSION="14"      # macOS versiyonu (11,12,13,14,15)
  - RAM_SIZE="4G"     # RAM miktarı
  - CPU_CORES="2"     # CPU çekirdek sayısı
  - DISK_SIZE="64G"   # Disk boyutu
  - WIDTH="2560"      # Ekran genişliği
  - HEIGHT="1440"     # Ekran yüksekliği
```

## 📋 macOS Kurulum Adımları

1. **Container başlat**: `docker-compose up -d`
2. **Web UI aç**: http://localhost:3050
3. **Recovery'de**: Disk Utility → Format et (APFS)
4. **Kurulum**: Reinstall macOS → Formatladığın diski seç
5. **Bekle**: 30-60 dakika kurulum süresi
6. **İlk setup**: Dil, kullanıcı hesabı vb.

## 🛠 Yönetim

```bash
# Başlat
docker-compose up -d

# Durdur (macOS'u kapat)
docker-compose stop

# Tamamen kaldır
docker-compose down -v

# Logları görüntüle
docker-compose logs
```

## 🔒 Güvenlik

- Container içinde izole çalışır
- Ana sisteme erişim yok
- Development ve test amaçlı
- Apple EULA dikkat edilmeli

## 📚 Daha Fazla

- Detaylı komutlar için: `docker-macos-cli.md`
- macOS versiyonları: 11 (Big Sur) - 15 (Sequoia)
- VNC client önerileri: RealVNC, TigerVNC
- Mac model emülasyonu mevcut