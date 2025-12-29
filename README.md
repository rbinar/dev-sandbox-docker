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

- **[sandbox-chromium](./sandbox-chromium/)** - İzole Chromium tarayıcı ortamı
  - Güvenilmeyen web sitelerini güvenle ziyaret etme
  - Şüpheli dosyaları ana sistemden bağımsız indirme/test etme
  - Web geliştirme projelerini güvenli ortamda test etme

- **[sandbox-code-server](./sandbox-code-server/)** - İzole VS Code editör ortamı  
  - Güvenilmeyen kodları ana sistemi etkilemeden çalıştırma
  - Şüpheli extension'ları güvenle test etme
  - Hassas projelerinizi izole ortamda geliştirme
  - **Erişim**: http://localhost:8443

- **[sandbox-webtop](./sandbox-webtop/)** - Tam Linux Desktop + ClamAV Antivirus
  - Şüpheli dosyaları izole Linux ortamında analiz etme
  - Güvenilmeyen yazılımları ana sistem riske atmadan test etme
  - Built-in ClamAV virüs tarayıcısı ile real-time koruma
  - **Erişim**: http://localhost:3010

- **[sandbox-libreoffice](./sandbox-libreoffice/)** - İzole Office ortamı
  - Şüpheli .docx, .xlsx, .pptx dosyalarını güvenle açma
  - Macro virüsleri ve Office exploit'larından korunma
  - PDF dosyalarını güvenli ortamda görüntüleme
  - **Erişim**: http://localhost:3020

- **[sandbox-jupyter](./sandbox-jupyter/)** - İzole Data Science ortamı
  - Bilinmeyen Jupyter notebook'larını güvenle çalıştırma
  - Şüpheli Python kodlarını ana sistem etkilemeden test etme
  - Data science projelerini izole ortamda geliştirme
  - **Erişim**: http://localhost:8888

- **[sandbox-antivirus](./sandbox-antivirus/)** - Specialized Virus Scanner
  - Özel virüs tarama ortamı (ClamAV + Web UI)
  - Drag & drop dosya tarama ara yüzü
  - Toplu dosya analizi ve quarantine yönetimi
  - REST API ile otomatik entegrasyon
  - **Erişim**: http://localhost:3031 (Web UI)

- **[sandbox-windows](./sandbox-windows/)** - İzole Windows 11 Pro Ortamı
  - Güvenilmeyen Windows yazılımlarını ana sistem riske atmadan test etme
  - Windows malware analizi ve güvenlik araştırması
  - Legacy Windows uygulamalarını güvenli ortamda çalıştırma
  - **Erişim**: http://localhost:3040 (Web UI), RDP: localhost:3041

- **[sandbox-macos](./sandbox-macos/)** - İzole macOS Sonoma Ortamı
  - macOS/iOS geliştirme için güvenli test ortamı
  - Şüpheli macOS uygulamalarını ana sistem etkilemeden test etme
  - Cross-platform geliştirme ve uyumluluk testleri
  - **Erişim**: http://localhost:3050 (Web UI), VNC: localhost:3051

### 🚀 Otomatik Kurulum

**Kolay kurulum için setup scriptlerini kullanın:**

<img width="1622" height="1392" alt="image" src="https://github.com/user-attachments/assets/bdf1e9d3-490f-4f81-b4bf-f2ab9e1f5aa0" />

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
3. 🎯 Size 8 farklı sandbox seçeneği sunar:
   - 🌐 Chromium Browser (Güvenli web browsing)
   - 💻 VS Code Server (İzole kod editörü)
   - 🖥️ Webtop + ClamAV (Linux desktop + antivirus)
   - 📄 LibreOffice (Güvenli Office dosyaları)
   - 📊 Jupyter Notebook (Data science)
   - 🦠 Antivirus Scanner (Özel virüs tarama)
   - 🪟 Windows Sandbox (İzole Windows 11)
   - 🍎 macOS Sandbox (İzole macOS Sonoma)
4. 🚀 Seçtiğiniz sandbox'ı başlatır
5. 🗑️ İstendiğinde temizlik yapar

### 🛠️ Manuel Kurulum

Eğer manuel kurulum tercih ediyorsanız:

```bash
# Chromium Browser
cd sandbox-chromium && docker-compose up -d

# VS Code Server (şifre: docker-compose.yml'de ayarlayın)
cd sandbox-code-server && docker-compose up -d

# Webtop Linux Desktop (ClamAV dahil değil, setup script önerilir)
cd sandbox-webtop && docker-compose up -d

# LibreOffice
cd sandbox-libreoffice && docker-compose up -d

# Jupyter Notebook (token: docker-compose.yml'de ayarlayın)
cd sandbox-jupyter && docker-compose up -d

# Antivirus Scanner (ClamAV + Web UI)
cd sandbox-antivirus && docker-compose up -d

# Windows Sandbox (İzole Windows 11 Pro)
cd sandbox-windows && docker-compose up -d

# macOS Sandbox (İzole macOS Sonoma)
cd sandbox-macos && docker-compose up -d
```

### ⚠️ Güvenlik Uyarıları

- Her sandbox kullanımdan sonra temizlenebilir: **Setup script'teki "Temizlik" seçeneğini kullanın**
- Container'lar ana sistem dosyalarına erişemez
- Network trafiği kontrollü ve izlenebilir
- Şüphe durumunda tam temizlik yapabilirsiniz

### 🗑️ Temizlik Seçenekleri

Setup script aracılığıyla:
1. **Container Durdur** - Sandbox'ları durdurur (veriler korunur)
2. **Sandbox Sıfırla** - Container'ları + verileri siler (temiz başlangıç)
3. **Tam Temizlik** - Her şeyi siler (container + image + veriler)

> **💡 Sandbox Felsefesi**: Her test/deneme sonrası "Sandbox Sıfırla" kullanarak temiz ortamda başlayın!

---
