# Windows Sandbox - Manuel Docker Komutları

## Hızlı Başlatma
```bash
# Windows 11 container'ını başlat
docker run -d \
  --name sandbox-windows \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -p 3040:8006 \
  -p 3041:3389/tcp \
  -p 3042:3389/udp \
  -v windows_data:/storage \
  -v ./shared:/shared \
  --stop-timeout 120 \
  -e VERSION="11" \
  -e RAM_SIZE="4G" \
  -e CPU_CORES="2" \
  -e USERNAME="Docker" \
  -e PASSWORD="admin" \
  -e LANGUAGE="Turkish" \
  dockurr/windows
```

## Erişim Yolları
- **Web Browser UI**: http://localhost:3040
- **RDP Bağlantısı**: localhost:3041
  - Kullanıcı: `Docker`
  - Şifre: `admin`

## Windows Versiyonları
```bash
# Windows 10 Pro
docker run -e VERSION="10" dockurr/windows

# Windows 11 LTSC (uzun vadeli destek)
docker run -e VERSION="11l" dockurr/windows

# Windows Server 2022
docker run -e VERSION="2022" dockurr/windows

# Özel ISO kullanma
docker run -e VERSION="https://example.com/windows.iso" dockurr/windows
```

## Gelişmiş Yapılandırma
```bash
# Daha fazla kaynak ile çalıştırma
docker run \
  -e RAM_SIZE="8G" \
  -e CPU_CORES="4" \
  -e DISK_SIZE="128G" \
  dockurr/windows

# Özel kullanıcı ve şifre
docker run \
  -e USERNAME="admin" \
  -e PASSWORD="güvenli123" \
  dockurr/windows

# Manuel kurulum modu
docker run \
  -e MANUAL="Y" \
  dockurr/windows
```

## Container Yönetimi
```bash
# Container'ı durdur (Windows'u kapat)
docker stop sandbox-windows

# Container'ı kaldır
docker rm sandbox-windows

# Volume'u da sil (tüm veriler kaybolur!)
docker volume rm windows_data

# Container loglarını görüntüle
docker logs sandbox-windows

# Container içine terminal erişimi
docker exec -it sandbox-windows /bin/bash
```

## Dosya Paylaşımı
```bash
# Host'tan container'a dosya kopyala
docker cp dosya.txt sandbox-windows:/shared/

# Container'dan host'a dosya kopyala
docker cp sandbox-windows:/shared/dosya.txt ./

# Shared klasör oluştur
mkdir -p ./shared
docker run -v ./shared:/shared dockurr/windows
```

## Ağ Yapılandırması
```bash
# Bridge network ile
docker run --network bridge dockurr/windows

# Host network ile (tüm portlar açık)
docker run --network host dockurr/windows

# Özel macvlan network ile
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  vlan_network

docker run --network vlan_network dockurr/windows
```

## Sorun Giderme
```bash
# KVM desteğini kontrol et
sudo apt install cpu-checker
sudo kvm-ok

# Container kaynaklarını izle
docker stats sandbox-windows

# Container içindeki süreçleri görüntüle
docker exec sandbox-windows ps aux

# Windows kurulum durumunu kontrol et
docker exec sandbox-windows cat /run/version
```

## Güvenlik Notları
- Container tam izole çalışır
- Ana sistem kaynaklarına erişimi yoktur
- Tüm işlemler virtualization layer'da gerçekleşir
- KVM desteği gerektirir (çoğu modern sistem destekler)
- Windows lisansı gerekebilir (trial sürümler mevcut)