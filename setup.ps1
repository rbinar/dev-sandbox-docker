# Dev Sandbox Docker - Setup Script for Windows PowerShell
# Bu script Docker Desktop kurulumunu kontrol eder ve sandbox seçimi yapar

Write-Host "🚀 Dev Sandbox Docker Setup" -ForegroundColor Blue
Write-Host "==========================" -ForegroundColor Blue

# Docker Desktop kurulumu kontrol fonksiyonu
function Test-DockerInstallation {
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Host "✓ Docker Desktop kurulu ve çalışıyor" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "✗ Docker Desktop bulunamadı" -ForegroundColor Red
        return $false
    }
    return $false
}

# Docker Desktop kurulum fonksiyonu
function Install-DockerDesktop {
    Write-Host "📦 Docker Desktop kuruluyor..." -ForegroundColor Yellow
    
    # Chocolatey ile kurulum deneme
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey ile kurulum yapılıyor..." -ForegroundColor Yellow
        try {
            choco install docker-desktop -y
            Write-Host "✓ Docker Desktop Chocolatey ile kuruldu" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Chocolatey kurulumu başarısız" -ForegroundColor Red
            Show-ManualInstallInstructions
        }
    }
    # Winget ile kurulum deneme
    elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Winget ile kurulum yapılıyor..." -ForegroundColor Yellow
        try {
            winget install Docker.DockerDesktop
            Write-Host "✓ Docker Desktop Winget ile kuruldu" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Winget kurulumu başarısız" -ForegroundColor Red
            Show-ManualInstallInstructions
        }
    }
    else {
        Show-ManualInstallInstructions
    }
}

# Manuel kurulum talimatları
function Show-ManualInstallInstructions {
    Write-Host "Manuel kurulum gerekli:" -ForegroundColor Yellow
    Write-Host "1. https://www.docker.com/products/docker-desktop adresine gidin" -ForegroundColor White
    Write-Host "2. Windows için Docker Desktop'ı indirin ve kurun" -ForegroundColor White
    Write-Host "3. Kurulum tamamlandıktan sonra scripti yeniden çalıştırın" -ForegroundColor White
    exit 1
}

# Sandbox seçim menüsü
function Select-Sandbox {
    Write-Host "📋 Hangi işlemi yapmak istiyorsunuz?" -ForegroundColor Blue
    Write-Host "1) Chromium Browser Kur (Güvenli web browsing)" -ForegroundColor White
    Write-Host "2) VS Code Server Kur (İzole kod editörü)" -ForegroundColor White
    Write-Host "3) Webtop Kur (Tam Linux desktop)" -ForegroundColor White
    Write-Host "4) LibreOffice Kur (Güvenli Office dosyaları)" -ForegroundColor White
    Write-Host "5) Jupyter Notebook Kur (Data science)" -ForegroundColor White
    Write-Host "6) Antivirus Scanner Kur (Virüs tarama)" -ForegroundColor White
    Write-Host "7) Windows Sandbox Kur (İzole Windows)" -ForegroundColor White
    Write-Host "8) macOS Sandbox Kur (İzole macOS)" -ForegroundColor White
    Write-Host "9) AI Harness Sandbox Kur (Claude Code, Codex, Antigravity, OpenCode, Copilot)" -ForegroundColor White
    Write-Host "10) Tüm Sandbox'ları Kur" -ForegroundColor White
    Write-Host "11) Sandbox'ları Kaldır/Temizle" -ForegroundColor White
    Write-Host "12) Çıkış" -ForegroundColor White

    $choice = Read-Host "Seçiminizi yapın [1-12]"
    
    switch ($choice) {
        "1" {
            Write-Host "🌐 Chromium Browser sandbox kuruluyor..." -ForegroundColor Green
            Set-Location "sandbox-chromium"
            docker-compose up -d
            Write-Host "✓ Chromium hazır! Erişim: https://localhost:3001" -ForegroundColor Green
        }
        "2" {
            Write-Host "💻 VS Code Server sandbox kuruluyor..." -ForegroundColor Green
            Setup-CodeServer
            Write-Host "✓ Code Server hazır! Erişim: http://localhost:8443" -ForegroundColor Green
        }
        "3" {
            Write-Host "🖥️ Webtop Linux Desktop kuruluyor..." -ForegroundColor Green
            Setup-WebtopWithAntivirus
            Write-Host "✓ Webtop + ClamAV hazır! Erişim: http://localhost:3010" -ForegroundColor Green
        }
        "4" {
            Write-Host "📄 LibreOffice sandbox kuruluyor..." -ForegroundColor Green
            Set-Location "sandbox-libreoffice"
            docker-compose up -d
            Set-Location ".."
            Write-Host "✓ LibreOffice hazır! Erişim: http://localhost:3020" -ForegroundColor Green
        }
        "5" {
            Write-Host "📊 Jupyter Notebook sandbox kuruluyor..." -ForegroundColor Green
            Setup-Jupyter
            Write-Host "✓ Jupyter hazır! Erişim: http://localhost:8888" -ForegroundColor Green
        }
        "6" {
            Write-Host "🦠 Antivirus Scanner kuruluyor..." -ForegroundColor Green
            Setup-Antivirus
            Write-Host "✓ Antivirus hazır! Web UI: http://localhost:3031" -ForegroundColor Green
        }
        "7" {
            Write-Host "🪟 Windows Sandbox kuruluyor..." -ForegroundColor Green
            Setup-Windows
            Write-Host "✓ Windows hazır! Web UI: http://localhost:3040, RDP: localhost:3041" -ForegroundColor Green
        }
        "8" {
            Write-Host "🍎 macOS Sandbox kuruluyor..." -ForegroundColor Green
            Setup-MacOS
            Write-Host "✓ macOS hazır! Web UI: http://localhost:3050, VNC: localhost:3051" -ForegroundColor Green
        }
        "9" {
            Write-Host "🤖 AI Harness Sandbox kuruluyor..." -ForegroundColor Green
            Setup-Harness
            Write-Host "✓ Harness hazır! Web UI: http://localhost:3060" -ForegroundColor Green
        }
        "10" {
            Write-Host "🚀 Tüm sandbox'lar kuruluyor..." -ForegroundColor Green
            Push-Location "sandbox-chromium"
            docker-compose up -d
            Pop-Location
            Setup-CodeServer
            Setup-WebtopWithAntivirus
            Push-Location "sandbox-libreoffice"
            docker-compose up -d
            Pop-Location
            Setup-Jupyter
            Setup-Antivirus
            Setup-Windows
            Setup-MacOS
            Setup-Harness
            Write-Host "✓ Chromium: https://localhost:3001" -ForegroundColor Green
            Write-Host "✓ Code Server: http://localhost:8443" -ForegroundColor Green
            Write-Host "✓ Webtop + ClamAV: http://localhost:3010" -ForegroundColor Green
            Write-Host "✓ LibreOffice: http://localhost:3020" -ForegroundColor Green
            Write-Host "✓ Jupyter: http://localhost:8888" -ForegroundColor Green
            Write-Host "✓ Antivirus: http://localhost:3031" -ForegroundColor Green
            Write-Host "✓ Windows: http://localhost:3040 (RDP: 3041)" -ForegroundColor Green
            Write-Host "✓ macOS: http://localhost:3050 (VNC: 3051)" -ForegroundColor Green
            Write-Host "✓ AI Harness: http://localhost:3060" -ForegroundColor Green
        }
        "11" {
            Show-CleanupMenu
        }
        "12" {
            Write-Host "👋 Çıkılıyor..." -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red
            Select-Sandbox
        }
    }
}

# Code Server kurulum fonksiyonu
function Setup-CodeServer {
    Write-Host "🔐 Code Server için şifre belirleme" -ForegroundColor Yellow
    $userPassword = Read-Host "Code Server şifresi girin (boş bırakırsanız 'admin123' kullanılır)" -AsSecureString
    
    if ($userPassword.Length -eq 0) {
        $plainPassword = "admin123"
        Write-Host "Varsayılan şifre kullanılıyor: admin123" -ForegroundColor Yellow
    } else {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($userPassword))
    }
    
    # docker-compose.yml dosyasında şifreyi güncelle
    Push-Location "sandbox-code-server"
    $content = Get-Content "docker-compose.yml" -Raw
    $updatedContent = $content -replace "PASSWORD=degistir-bunu", "PASSWORD=$plainPassword"
    Set-Content "docker-compose.yml" -Value $updatedContent
    docker-compose up -d
    Write-Host "✓ Şifreniz: $plainPassword" -ForegroundColor Green
    Pop-Location
}

# Jupyter kurulum fonksiyonu
function Setup-Jupyter {
    Write-Host "🔐 Jupyter için token belirleme" -ForegroundColor Yellow
    $userToken = Read-Host "Jupyter token girin (boş bırakırsanız 'admin123' kullanılır)" -AsSecureString
    
    if ($userToken.Length -eq 0) {
        $plainToken = "admin123"
        Write-Host "Varsayılan token kullanılıyor: admin123" -ForegroundColor Yellow
    } else {
        $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($userToken))
    }
    
    # docker-compose.yml dosyasında token'ı güncelle
    Push-Location "sandbox-jupyter"
    $content = Get-Content "docker-compose.yml" -Raw
    $updatedContent = $content -replace "JUPYTER_TOKEN=degistir-bunu", "JUPYTER_TOKEN=$plainToken"
    $updatedContent = $updatedContent -replace "--NotebookApp.token='degistir-bunu'", "--NotebookApp.token='$plainToken'"
    Set-Content "docker-compose.yml" -Value $updatedContent
    docker-compose up -d
    Write-Host "✓ Token'ınız: $plainToken" -ForegroundColor Green
    Pop-Location
}

# Webtop + ClamAV kurulum fonksiyonu
function Setup-WebtopWithAntivirus {
    Write-Host "🦠 Webtop + ClamAV virüs tarayıcısı kuruluyor..." -ForegroundColor Yellow
    
    # Webtop container'ını başlat
    Push-Location "sandbox-webtop"
    docker-compose up -d
    Pop-Location
    
    # Container'ın tamamen başlamasını bekle
    Write-Host "⏳ Webtop'un başlaması bekleniyor..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    # ClamAV kur (Alpine Linux için)
    Write-Host "🔧 ClamAV virüs tarayıcısı kuruluyor..." -ForegroundColor Yellow
    docker exec sandbox-webtop apk update
    docker exec sandbox-webtop apk add clamav clamav-daemon freshclam
    
    # ClamAV database güncelle
    Write-Host "📡 Virüs veritabanı güncelleniyor..." -ForegroundColor Yellow
    docker exec sandbox-webtop freshclam
    
    # Test dosyası oluştur
    docker exec sandbox-webtop sh -c 'echo "ClamAV kuruldu! Test için: clamscan --version" > /config/Desktop/ClamAV-Test.txt'
    
    Write-Host "✅ ClamAV başarıyla kuruldu!" -ForegroundColor Green
    Write-Host "💡 Test için: Terminal açıp 'clamscan --version' yazın" -ForegroundColor Blue
}

# Antivirus kurulum fonksiyonu
function Setup-Antivirus {
    Write-Host "🦠 İzole ClamAV Antivirus Scanner kuruluyor..." -ForegroundColor Yellow
    
    # Antivirus container'ını başlat
    Push-Location "sandbox-antivirus"
    docker-compose up -d
    Pop-Location
    
    # Container'ın tamamen başlamasını bekle
    Write-Host "⏳ ClamAV'ın başlaması ve database güncellenmesi bekleniyor (90 saniye)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 90
    
    # Test dosyası oluştur (container içinde)
    Write-Host "🔧 Test virüs dosyası oluşturuluyor..." -ForegroundColor Yellow
    docker exec sandbox-antivirus sh -c "echo 'X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*' > /scan/eicar-test.txt"
    
    # Test tarama
    Write-Host "🔍 Test tarama yapılıyor..." -ForegroundColor Yellow
    try { docker exec sandbox-antivirus clamdscan /scan/eicar-test.txt } catch { }
    
    Write-Host "✅ İzole Antivirus Scanner başarıyla kuruldu!" -ForegroundColor Green
    Write-Host "💡 Web UI: http://localhost:3031" -ForegroundColor Blue
    Write-Host "� TAM İZOLASYON: Ana sistem bağlantısı YOK" -ForegroundColor Blue
    Write-Host "💡 Dosya kopyalama: docker cp dosya.exe sandbox-antivirus:/scan/" -ForegroundColor Blue
    Write-Host "💡 Tarama: docker exec sandbox-antivirus clamdscan /scan/dosya.exe" -ForegroundColor Blue
}

# Windows kurulum fonksiyonu
function Setup-Windows {
    Write-Host "🪟 Windows Sandbox kuruluyor..." -ForegroundColor Yellow
    
    # Windows container'ını başlat
    Push-Location "sandbox-windows"
    Write-Host "💡 Windows 11 Pro kuruluyor (Türkçe)" -ForegroundColor Blue
    Write-Host "  • RAM: 4GB, CPU: 2 core, Disk: 64GB" -ForegroundColor White
    Write-Host "  • Username: Docker, Password: admin" -ForegroundColor White
    
    docker-compose up -d
    
    Write-Host "⏳ Windows kurulumu başlıyor (10-30 dakika)..." -ForegroundColor Yellow
    Write-Host "✅ Windows Sandbox başlatıldı!" -ForegroundColor Green
    Write-Host "💡 Web UI: http://localhost:3040" -ForegroundColor Blue
    Write-Host "💡 RDP: localhost:3041 (Docker/admin)" -ForegroundColor Blue
    
    Pop-Location
}

# macOS kurulum fonksiyonu
function Setup-MacOS {
    Write-Host "🍎 macOS Sandbox kuruluyor..." -ForegroundColor Yellow
    
    # macOS container'ını başlat
    Push-Location "sandbox-macos"
    Write-Host "💡 macOS 14 Sonoma kuruluyor" -ForegroundColor Blue
    Write-Host "  • RAM: 4GB, CPU: 2 core, Disk: 64GB" -ForegroundColor White
    Write-Host "  • Web UI: 3050, VNC: 3051/3052" -ForegroundColor White
    
    docker-compose up -d
    
    Write-Host "⏳ macOS kurulumu başlıyor (30-60 dakika)..." -ForegroundColor Yellow
    Write-Host "✅ macOS Sandbox başlatıldı!" -ForegroundColor Green
    Write-Host "💡 Web UI: http://localhost:3050" -ForegroundColor Blue
    Write-Host "💡 VNC: localhost:3051" -ForegroundColor Blue
    Write-Host "📋 Kurulum: Recovery → Disk Utility → Format (APFS) → Reinstall macOS" -ForegroundColor Yellow
    
    Pop-Location
}

# AI Harness kurulum fonksiyonu
function Setup-Harness {
    Write-Host "🤖 AI Harness Sandbox kuruluyor..." -ForegroundColor Yellow

    Push-Location "sandbox-harness"
    Write-Host "💡 Tek container, 5 AI coding harness'ı" -ForegroundColor Blue
    Write-Host "  • Claude Code, Codex, Antigravity, OpenCode, GitHub Copilot" -ForegroundColor White
    Write-Host "  • Web picker: 3060, terminaller: 3061-3065" -ForegroundColor White
    Write-Host "  • Portlar yalnızca 127.0.0.1'e bağlı" -ForegroundColor White

    # İlk çalıştırmada imaj derlenir (harness'lar npm'den kurulur) — birkaç dakika.
    Write-Host "⏳ İmaj derleniyor (ilk sefer 3-6 dakika)..." -ForegroundColor Yellow
    docker-compose up -d --build

    Write-Host "✅ AI Harness Sandbox başlatıldı!" -ForegroundColor Green
    Write-Host "💡 Web UI: http://localhost:3060" -ForegroundColor Blue
    Write-Host "📋 Her harness'a container içinde bir kez login ol —" -ForegroundColor Yellow
    Write-Host "   oturumlar volume'de kalıcı, host kimlikleri mount EDİLMEZ." -ForegroundColor Yellow

    Pop-Location
}

# Temizlik menüsü
function Show-CleanupMenu {
    Write-Host "🗑️  Sandbox Temizlik Menüsü" -ForegroundColor Red
    Write-Host "1) Sadece Container'ları Durdur (veriler korunur)" -ForegroundColor White
    Write-Host "2) Container'ları + Verileri Sil (sandbox sıfırla)" -ForegroundColor White
    Write-Host "3) Container'ları + Image'ları + Verileri Sil (tam temizlik)" -ForegroundColor White
    Write-Host "4) Ana Menüye Dön" -ForegroundColor White
    
    $cleanupChoice = Read-Host "Temizlik seviyesini seçin [1-4]"
    
    switch ($cleanupChoice) {
        "1" { Stop-Containers }
        "2" { Stop-AndRemoveContainers }
        "3" { Start-FullCleanup }
        "4" { Select-Sandbox }
        default {
            Write-Host "❌ Geçersiz seçim!" -ForegroundColor Red
            Show-CleanupMenu
        }
    }
}

# Container'ları durdur
function Stop-Containers {
    Write-Host "⏹️  Container'lar durduruluyor..." -ForegroundColor Yellow
    
    if (Test-Path "sandbox-chromium") {
        Push-Location "sandbox-chromium"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Chromium container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-code-server") {
        Push-Location "sandbox-code-server"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Code Server container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-webtop") {
        Push-Location "sandbox-webtop"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Webtop container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-libreoffice") {
        Push-Location "sandbox-libreoffice"
        docker-compose stop
        Pop-Location
        Write-Host "✓ LibreOffice container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-jupyter") {
        Push-Location "sandbox-jupyter"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Jupyter container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-antivirus") {
        Push-Location "sandbox-antivirus"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Antivirus container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-windows") {
        Push-Location "sandbox-windows"
        docker-compose stop
        Pop-Location
        Write-Host "✓ Windows container'ı durduruldu" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-macos") {
        Push-Location "sandbox-macos"
        docker-compose stop
        Pop-Location
        Write-Host "✓ macOS container'ı durduruldu" -ForegroundColor Green
    }

    if (Test-Path "sandbox-harness") {
        Push-Location "sandbox-harness"
        docker-compose stop
        Pop-Location
        Write-Host "✓ AI Harness container'ı durduruldu" -ForegroundColor Green
    }

    Write-Host "🎉 Tüm container'lar durduruldu!" -ForegroundColor Green
    Read-Host "Ana menüye dönmek için Enter'a basın"
    Select-Sandbox
}

# Container'ları durdur ve sil
function Stop-AndRemoveContainers {
    Write-Host "🗑️  Container'lar ve veriler siliniyor..." -ForegroundColor Yellow
    
    if (Test-Path "sandbox-chromium") {
        Push-Location "sandbox-chromium"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Chromium container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-code-server") {
        Push-Location "sandbox-code-server"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Code Server container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-webtop") {
        Push-Location "sandbox-webtop"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Webtop container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-libreoffice") {
        Push-Location "sandbox-libreoffice"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ LibreOffice container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-jupyter") {
        Push-Location "sandbox-jupyter"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Jupyter container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-antivirus") {
        Push-Location "sandbox-antivirus"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Antivirus container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-windows") {
        Push-Location "sandbox-windows"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ Windows container'ı ve verileri silindi" -ForegroundColor Green
    }
    
    if (Test-Path "sandbox-macos") {
        Push-Location "sandbox-macos"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ macOS container'ı ve verileri silindi" -ForegroundColor Green
    }

    if (Test-Path "sandbox-harness") {
        Push-Location "sandbox-harness"
        docker-compose down -v
        Pop-Location
        Write-Host "✓ AI Harness container'ı ve verileri silindi (login'ler dahil)" -ForegroundColor Green
    }

    Write-Host "🎉 Tüm container'lar ve veriler silindi! (Temiz sandbox)" -ForegroundColor Green
    Read-Host "Ana menüye dönmek için Enter'a basın"
    Select-Sandbox
}

# Tam temizlik (container + image)
function Start-FullCleanup {
    Write-Host "⚠️  TAM TEMİZLİK UYARISI!" -ForegroundColor Red
    Write-Host "Bu işlem şunları silecek:" -ForegroundColor Yellow
    Write-Host "• Tüm sandbox container'ları" -ForegroundColor White
    Write-Host "• Tüm sandbox image'ları" -ForegroundColor White
    Write-Host "• Volume'ları (veriler kaybolacak!)" -ForegroundColor White
    Write-Host ""
    
    $confirm = Read-Host "Emin misiniz? (yes/no)"
    
    if ($confirm -match "^(yes|y|Y)$") {
        Write-Host "🔥 Tam temizlik başlıyor..." -ForegroundColor Red
        
        # Container'ları durdur ve sil
        if (Test-Path "sandbox-chromium") {
            Push-Location "sandbox-chromium"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-code-server") {
            Push-Location "sandbox-code-server"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-webtop") {
            Push-Location "sandbox-webtop"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-libreoffice") {
            Push-Location "sandbox-libreoffice"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-jupyter") {
            Push-Location "sandbox-jupyter"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-antivirus") {
            Push-Location "sandbox-antivirus"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-windows") {
            Push-Location "sandbox-windows"
            docker-compose down -v
            Pop-Location
        }
        
        if (Test-Path "sandbox-macos") {
            Push-Location "sandbox-macos"
            docker-compose down -v
            Pop-Location
        }

        if (Test-Path "sandbox-harness") {
            Push-Location "sandbox-harness"
            docker-compose down -v
            Pop-Location
        }

        # Image'ları sil
        Write-Host "📦 Image'lar siliniyor..." -ForegroundColor Yellow
        try { docker rmi lscr.io/linuxserver/chromium:5f5dd27e-ls102 } catch { }
        try { docker rmi lscr.io/linuxserver/code-server:latest } catch { }
        try { docker rmi lscr.io/linuxserver/webtop:latest } catch { }
        try { docker rmi lscr.io/linuxserver/libreoffice:latest } catch { }
        try { docker rmi jupyter/datascience-notebook:latest } catch { }
        try { docker rmi alpine:latest } catch { }
        try { docker rmi nginx:alpine } catch { }
        try { docker rmi dockurr/windows:latest } catch { }
        try { docker rmi dockurr/macos:latest } catch { }
        
        # Kullanılmayan volume'ları temizle
        try { docker volume prune -f } catch { }
        
        Write-Host "🎉 Tam temizlik tamamlandı!" -ForegroundColor Green
        Write-Host "💡 Yeni kurulum yapmak için tekrar script'i çalıştırabilirsiniz" -ForegroundColor Blue
        
    } else {
        Write-Host "✅ Temizlik iptal edildi" -ForegroundColor Green
    }
    
    Read-Host "Ana menüye dönmek için Enter'a basın"
    Select-Sandbox
}

# Ana çalışma fonksiyonu
function Main {
    Write-Host "🔍 Docker Desktop kontrol ediliyor..." -ForegroundColor Blue
    
    if (Test-DockerInstallation) {
        Write-Host "Docker Desktop hazır!" -ForegroundColor Green
    }
    else {
        Write-Host "Docker Desktop kurulumu gerekli" -ForegroundColor Yellow
        $installChoice = Read-Host "Docker Desktop'ı kurmak istiyor musunuz? [y/N]"
        
        if ($installChoice -match "^[Yy]$") {
            Install-DockerDesktop
            
            Write-Host "⏳ Docker Desktop'ın başlatılması bekleniyor..." -ForegroundColor Yellow
            Start-Sleep -Seconds 15
            
            if (Test-DockerInstallation) {
                Write-Host "✓ Docker Desktop başarıyla kuruldu ve çalışıyor" -ForegroundColor Green
            }
            else {
                Write-Host "❌ Docker Desktop kurulumu tamamlanamadı" -ForegroundColor Red
                Write-Host "Lütfen manuel olarak Docker Desktop'ı başlatın ve scripti yeniden çalıştırın" -ForegroundColor Yellow
                exit 1
            }
        }
        else {
            Write-Host "❌ Docker Desktop kurulumu iptal edildi" -ForegroundColor Red
            exit 1
        }
    }
    
    Select-Sandbox
}

# Script başlat
Main