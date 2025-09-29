# Dev Sandbox Docker

## Neden Güvenli Sandbox Ortamları Kritik Önemde?

Bir yazılım geliştiricisi olarak, **güvenlik** öncelikli sandbox ortamları kullanmak hayati önem taşır. Özellikle tarayıcı ve kod editörü gibi hassas araçlar için:

### 🛡️ **Tarayıcı Güvenliği (Chromium Sandbox)**
- **İzole web browsing**: Ana sisteminizde zararlı web sitelerine maruz kalmadan güvenli gezinme
- **Şüpheli dosya indirme**: Güvenilmeyen dosyaları ana sisteminizi riske atmadan test etme
- **Web geliştirme testi**: Farklı extension'lar ve ayarları güvenle deneme
- **Kötü amaçlı kod koruması**: JavaScript ve diğer web kodlarından ana sistemi koruma

### � **Kod Editörü Güvenliği (Code-Server Sandbox)**
- **Güvenilmeyen kod çalıştırma**: Bilinmeyen kaynaklardan gelen kodları izole ortamda test etme
- **Extension güvenliği**: Şüpheli VS Code extension'larını ana sistemi etkilemeden deneme
- **Proje izolasyonu**: Farklı projeleri birbirinden bağımsız ortamlarda geliştirme
- **Hassas veri koruması**: Ana sistemdeki kişisel verilerinizi riske atmadan çalışma

### 🔒 **Docker İzolasyon Avantajları**
- **Container izolasyonu**: Her sandbox kendi kapalı ekosisteminde çalışır
- **Kaynak sınırlama**: Sisteminizdeki kaynakları kontrollü şekilde kullanma
- **Hızlı temizlik**: Şüphe durumunda container'ı anında silip temiz başlangıç
- **Network izolasyonu**: Ağ trafiğini kontrol altında tutma

---

## Bu Repository Hakkında

Bu repository, **güvenlik odaklı** Docker sandbox ortamları koleksiyonudur. Ana sisteminizi riske atmadan güvenli geliştirme ve test ortamları sağlar.

### 📁 Güvenli Sandbox'lar

- **[docker-chromium](./docker-chromium/)** - İzole Chromium tarayıcı ortamı
  - Güvenilmeyen web sitelerini güvenle ziyaret etme
  - Şüpheli dosyaları ana sistemden bağımsız indirme/test etme
  - Web geliştirme projelerini güvenli ortamda test etme

- **[docker-code-server](./docker-code-server/)** - İzole VS Code editör ortamı  
  - Güvenilmeyen kodları ana sistemi etkilemeden çalıştırma
  - Şüpheli extension'ları güvenle test etme
  - Hassas projelerinizi izole ortamda geliştirme
  - **Erişim**: http://localhost:8443

### 🚀 Otomatik Kurulum

**Kolay kurulum için setup scriptlerini kullanın:**

#### macOS/Linux:
```bash
chmod +x setup.sh
./setup.sh
```

#### Windows PowerShell:
```powershell
.\setup.ps1
```

Setup script şunları yapar:
1. ✅ Docker Desktop kurulumunu kontrol eder
2. 📦 Kurulu değilse otomatik kurulum yapar
3. 🎯 Size sandbox/temizlik seçeneği sunar
4. 🚀 Seçtiğiniz sandbox'ı başlatır
5. 🗑️ İstendiğinde temizlik yapar

### 🛠️ Manuel Kurulum

Eğer manuel kurulum tercih ediyorsanız:

```bash
cd docker-chromium  # veya docker-code-server
docker-compose up -d
# Güvenli ortamınız hazır!
```

### ⚠️ Güvenlik Uyarıları

- Her sandbox kullanımdan sonra temizlenebilir: **Setup script'teki "Temizlik" seçeneğini kullanın**
- Container'lar ana sistem dosyalarına erişemez
- Network trafiği kontrollü ve izlenebilir
- Şüphe durumunda tam temizlik yapabilirsiniz

### 🗑️ Temizlik Seçenekleri

Setup script aracılığıyla:
1. **Container Durdur** - Sandbox'ları durdurur (veriler korunur)
2. **Container Sil** - Container'ları siler (image'lar kalır)
3. **Tam Temizlik** - Her şeyi siler (container + image + volume'lar)

---
