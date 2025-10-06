# Windows Sandbox 🪟

Windows işletim sistemini Docker container'ında güvenle çalıştırın!

## ✨ Özellikler

### 🖥️ Tam Windows Deneyimi
- **Windows 11/10/7/XP** desteği
- **Web browser** ile erişim
- **Remote Desktop (RDP)** bağlantısı
- **Türkçe dil** ve klavye desteği

### 🛡️ Güvenlik
- **Tam izolasyon** - Ana sisteme erişim yok
- **KVM virtualization** ile native performans
- **Snapshot** ve backup desteği
- **Volume encryption** mümkün

### 🔄 Dosya Paylaşımı
- Host ile **shared folder**
- **Drag & drop** dosya aktarımı
- **Clipboard** paylaşımı (RDP ile)

## 🚀 Hızlı Başlatma

```bash
# Docker Compose ile
cd sandbox-windows
docker-compose up -d

# Manuel Docker ile
docker run -d --name sandbox-windows \
  --device=/dev/kvm --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -p 3040:8006 -p 3041:3389 \
  -v windows_data:/storage \
  dockurr/windows
```

## 🌐 Erişim

### Web Browser UI
- **URL**: http://localhost:3040
- **Kullanım**: Windows kurulumu ve kullanımı
- **Özellik**: Tam web tabanlı masaüstü

### Remote Desktop (RDP)
- **Adres**: localhost:3041
- **Kullanıcı**: Docker
- **Şifre**: admin
- **Client**: Microsoft Remote Desktop

## ⚙️ Yapılandırma

### Donanım Ayarları
```yaml
environment:
  RAM_SIZE: "8G"      # RAM miktarı
  CPU_CORES: "4"      # İşlemci çekirdek sayısı
  DISK_SIZE: "128G"   # Disk boyutu
```

### Windows Versiyonları
```yaml
environment:
  VERSION: "11"   # Windows 11 Pro
  VERSION: "10"   # Windows 10 Pro
  VERSION: "11l"  # Windows 11 LTSC
  VERSION: "2022" # Windows Server 2022
```

### Dil ve Bölge
```yaml
environment:
  LANGUAGE: "Turkish"  # Türkçe Windows
  KEYBOARD: "tr-TR"    # Türkçe klavye
  REGION: "tr-TR"      # Türkiye bölgesi
```

## 📁 Dosya Paylaşımı

### Shared Klasör
```bash
# Host'ta klasör oluştur
mkdir -p ./shared

# Container'da C:\Shared olarak görünür
volumes:
  - ./shared:/shared
```

### Dosya Aktarımı
```bash
# Host → Windows
cp dosya.txt ./shared/

# Windows → Host
# Windows'ta C:\Shared\dosya.txt kaydet
```

## 🔧 İleri Düzey

### Custom ISO Kullanma
```yaml
environment:
  VERSION: "https://example.com/windows.iso"
```

### Manuel Kurulum
```yaml
environment:
  MANUAL: "Y"  # Otomatik kurulumu devre dışı bırak
```

### Network Bridge
```yaml
environment:
  DHCP: "Y"    # Router'dan IP al
```

## 🔍 Sorun Giderme

### KVM Desteği Kontrol
```bash
# Linux'ta
sudo apt install cpu-checker
sudo kvm-ok

# macOS'ta (Desteklenmez)
# Docker Desktop gerekir ancak sınırlı
```

### Container Durumu
```bash
# Logları görüntüle
docker logs sandbox-windows

# Kaynak kullanımı
docker stats sandbox-windows

# Container içine gir
docker exec -it sandbox-windows /bin/bash
```

### Port Problemleri
```bash
# Portların kullanımda olup olmadığını kontrol et
lsof -i :3040
lsof -i :3041

# Alternatif portlar kullan
ports:
  - "3050:8006"  # Web UI
  - "3051:3389"  # RDP
```

## ⚠️ Gereksinimler

### Sistem Gereksinimleri
- **KVM desteği** (Intel VT-x / AMD SVM)
- **Docker Desktop** veya **Docker Engine**
- **4GB+ RAM** (Windows için)
- **2+ CPU core**

### İşletim Sistemi Desteği
- ✅ **Linux** (tam destek)
- ⚠️ **macOS** (Docker Desktop gerekli, sınırlı)
- ❌ **Windows** (nested virtualization gerekli)

## 📝 Notlar

### Lisans
- Windows **trial versiyonları** kullanılır
- Üretim için **geçerli lisans** gerekli
- Microsoft EULA'ya uygun kullanım

### Performans
- **Native'e yakın** performans (KVM sayesinde)
- **GPU acceleration** mümkün
- **SSD depolama** önerilir

### Güvenlik
- Container **tam izole**
- Host dosyalarına **erişim yok**
- Network **NAT** üzerinden
- **Malware analizi** için ideal

## 🎯 Kullanım Senaryoları

- **Windows uygulaması test**
- **Malware analizi**
- **Legacy software çalıştırma**
- **Cross-platform geliştirme**
- **Eğitim ve demo**
- **Güvenli Windows ortamı**