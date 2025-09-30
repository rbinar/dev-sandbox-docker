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
    Write-Host "3) İkisini de Kur" -ForegroundColor White
    Write-Host "4) Sandbox'ları Kaldır/Temizle" -ForegroundColor White
    Write-Host "5) Çıkış" -ForegroundColor White
    
    $choice = Read-Host "Seçiminizi yapın [1-5]"
    
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
            Write-Host "🚀 Her iki sandbox da kuruluyor..." -ForegroundColor Green
            Push-Location "sandbox-chromium"
            docker-compose up -d
            Pop-Location
            Setup-CodeServer
            Write-Host "✓ Chromium: https://localhost:3001" -ForegroundColor Green
            Write-Host "✓ Code Server: http://localhost:8443" -ForegroundColor Green
        }
        "4" {
            Show-CleanupMenu
        }
        "5" {
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
        
        # Image'ları sil
        Write-Host "📦 Image'lar siliniyor..." -ForegroundColor Yellow
        try { docker rmi lscr.io/linuxserver/chromium:5f5dd27e-ls102 } catch { }
        try { docker rmi lscr.io/linuxserver/code-server:latest } catch { }
        
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