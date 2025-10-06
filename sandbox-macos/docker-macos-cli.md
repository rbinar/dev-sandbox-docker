# macOS Sandbox - Manuel Docker Komutları

## Hızlı Başlatma
```bash
# macOS 14 Sonoma container'ını başlat
docker run -d \
  --name sandbox-macos \
  -p 3050:8006 \
  -p 3051:5900/tcp \
  -p 3052:5900/udp \
  -v macos_data:/storage \
  --stop-timeout 120 \
  -e VERSION="14" \
  -e RAM_SIZE="4G" \
  -e CPU_CORES="2" \
  dockurr/macos
```

## Erişim Yolları
- **Web Browser UI**: http://localhost:3050
- **VNC Bağlantısı**: localhost:3051
  - VNC client kullanarak macOS desktop'a erişim

## macOS Versiyonları
```bash
# macOS 15 Sequoia (Beta)
docker run -e VERSION="15" dockurr/macos

# macOS 14 Sonoma (Varsayılan)
docker run -e VERSION="14" dockurr/macos

# macOS 13 Ventura
docker run -e VERSION="13" dockurr/macos

# macOS 12 Monterey
docker run -e VERSION="12" dockurr/macos

# macOS 11 Big Sur
docker run -e VERSION="11" dockurr/macos
```

## Gelişmiş Yapılandırma
```bash
# Daha fazla kaynak ile çalıştırma
docker run \
  -e RAM_SIZE="8G" \
  -e CPU_CORES="4" \
  -e DISK_SIZE="128G" \
  -e WIDTH="2560" \
  -e HEIGHT="1440" \
  dockurr/macos

# Farklı Mac modeli emüle etme
docker run \
  -e MODEL="MacBookPro16,1" \
  dockurr/macos

# Özel ekran çözünürlüğü
docker run \
  -e WIDTH="1920" \
  -e HEIGHT="1080" \
  dockurr/macos
```

## Container Yönetimi
```bash
# Container'ı durdur (macOS'u kapat)
docker stop sandbox-macos

# Container'ı kaldır
docker rm sandbox-macos

# Volume'u da sil (tüm veriler kaybolur!)
docker volume rm macos_data

# Container loglarını görüntüle
docker logs sandbox-macos

# Container içine terminal erişimi
docker exec -it sandbox-macos /bin/bash
```

## Dosya Paylaşımı
```bash
# Shared folder oluştur (container içinden mount gerekli)
mkdir -p ./shared
docker run -v ./shared:/shared dockurr/macos

# macOS içinde shared folder'ı mount etme
sudo mount_9p shared /Users/Shared/Host
```

## macOS Kurulum Süreci
```bash
# 1. Container başlat ve web UI'ı aç
docker-compose up -d
open http://localhost:3050

# 2. macOS Recovery'de
# - Disk Utility seç
# - En büyük "Apple Inc. VirtIO Block Media" diski seç
# - Erase butonuna tıkla, APFS formatında format et

# 3. macOS yükleyicisinde
# - "Reinstall macOS" seç
# - Oluşturduğun diski seç
# - Kurulum tamamlanana kadar bekle (30-60 dakika)

# 4. İlk kurulum
# - Ülke ve dil seç
# - Apple ID (isteğe bağlı)
# - Kullanıcı hesabı oluştur
```

## Mac Model Referansları
```bash
# iMac Pro (Varsayılan)
MODEL="iMacPro1,1"

# MacBook Pro 16-inch 2019
MODEL="MacBookPro16,1"

# iMac 27-inch 2020
MODEL="iMac20,1"

# Mac Studio 2022
MODEL="Mac13,1"

# Mac Pro 2019
MODEL="MacPro7,1"
```

## Ağ Yapılandırması
```bash
# Bridge network ile
docker run --network bridge dockurr/macos

# Host network ile (Linux'ta)
docker run --network host dockurr/macos

# Özel macvlan network ile
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  vlan_network

docker run --network vlan_network dockurr/macos
```

## Sorun Giderme
```bash
# macOS indirme durumunu kontrol et
docker logs sandbox-macos | grep -i download

# Apple sunucularına bağlantıyı test et
docker exec sandbox-macos curl -I https://osrecovery.apple.com/

# Container kaynaklarını izle
docker stats sandbox-macos

# Disk kullanımını kontrol et
docker exec sandbox-macos df -h
```

## VNC Client'lar
```bash
# macOS
open vnc://localhost:3051

# Windows
# Microsoft Remote Desktop veya TightVNC

# Linux
sudo apt install vinagre
vinagre localhost:3051

# Cross-platform
# RealVNC Viewer
# TigerVNC
```

## Güvenlik ve Yasal Notlar
- **EULA Uyumluluğu**: Apple EULA'ya göre sadece Apple hardware'da legal
- **Tam İzolasyon**: Container içinde çalışır, ana sisteme erişim yok
- **Development Use**: iOS/macOS app geliştirme için ideal
- **Educational Purpose**: Eğitim ve test amaçlı kullanım

## Performans Optimizasyonu
```bash
# CPU önceliği artırma
docker run --cpus="2.0" --memory="8g" dockurr/macos

# SSD depolama kullanma (önemli)
# macOS için SSD şiddetle önerilir

# KVM desteği (sadece Linux)
docker run --device=/dev/kvm dockurr/macos
```