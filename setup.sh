#!/bin/bash

# Dev Sandbox Docker - Setup Script for macOS/Linux
# Bu script Docker Desktop kurulumunu kontrol eder ve sandbox seçimi yapar

echo "🚀 Dev Sandbox Docker Setup"
echo "=========================="

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Docker Desktop kurulumu kontrol fonksiyonu
check_docker() {
    if command -v docker &> /dev/null && docker --version &> /dev/null; then
        echo -e "${GREEN}✓ Docker Desktop kurulu ve çalışıyor${NC}"
        return 0
    else
        echo -e "${RED}✗ Docker Desktop bulunamadı${NC}"
        return 1
    fi
}

# Docker Desktop kurulum fonksiyonu
install_docker() {
    echo -e "${YELLOW}📦 Docker Desktop kuruluyor...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "macOS için Docker Desktop indiriliyor..."
        if command -v brew &> /dev/null; then
            echo "Homebrew ile kurulum yapılıyor..."
            brew install --cask docker
        else
            echo "Manuel kurulum gerekli:"
            echo "1. https://www.docker.com/products/docker-desktop adresine gidin"
            echo "2. Mac için Docker Desktop'ı indirin ve kurun"
            echo "3. Kurulum tamamlandıktan sonra scripti yeniden çalıştırın"
            exit 1
        fi
    else
        # Linux
        echo "Linux için Docker kurulumu..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        echo "Docker kuruldu. Yeniden oturum açın veya 'newgrp docker' komutunu çalıştırın"
    fi
}

# Sandbox seçim menüsü
select_sandbox() {
    echo -e "${BLUE}📋 Hangi işlemi yapmak istiyorsunuz?${NC}"
    echo "1) Chromium Browser Kur (Güvenli web browsing)"
    echo "2) VS Code Server Kur (İzole kod editörü)"
    echo "3) Webtop Kur (Tam Linux desktop)"
    echo "4) LibreOffice Kur (Güvenli Office dosyaları)"
    echo "5) Jupyter Notebook Kur (Data science)"
    echo "6) Antivirus Scanner Kur (Virüs tarama)"
    echo "7) Windows Sandbox Kur (İzole Windows)"
    echo "8) macOS Sandbox Kur (İzole macOS)"
    echo "9) Tüm Sandbox'ları Kur"
    echo "10) Sandbox'ları Kaldır/Temizle"
    echo "11) Çıkış"
    
    read -p "Seçiminizi yapın [1-11]: " choice
    
    case $choice in
        1)
            echo -e "${GREEN}🌐 Chromium Browser sandbox kuruluyor...${NC}"
            cd sandbox-chromium
            docker-compose up -d
            echo -e "${GREEN}✓ Chromium hazır! Erişim: https://localhost:3001${NC}"
            ;;
        2)
            echo -e "${GREEN}💻 VS Code Server sandbox kuruluyor...${NC}"
            setup_code_server
            echo -e "${GREEN}✓ Code Server hazır! Erişim: http://localhost:8443${NC}"
            ;;
        3)
            echo -e "${GREEN}🖥️ Webtop Linux Desktop kuruluyor...${NC}"
            setup_webtop_with_antivirus
            echo -e "${GREEN}✓ Webtop + ClamAV hazır! Erişim: http://localhost:3010${NC}"
            ;;
        4)
            echo -e "${GREEN}📄 LibreOffice sandbox kuruluyor...${NC}"
            cd sandbox-libreoffice
            docker-compose up -d
            echo -e "${GREEN}✓ LibreOffice hazır! Erişim: http://localhost:3020${NC}"
            ;;
        5)
            echo -e "${GREEN}📊 Jupyter Notebook sandbox kuruluyor...${NC}"
            setup_jupyter
            echo -e "${GREEN}✓ Jupyter hazır! Erişim: http://localhost:8888${NC}"
            ;;
        6)
            echo -e "${GREEN}🦠 Antivirus Scanner kuruluyor...${NC}"
            setup_antivirus
            echo -e "${GREEN}✓ Antivirus hazır! Web UI: http://localhost:3031${NC}"
            ;;
        7)
            echo -e "${GREEN}🪟 Windows Sandbox kuruluyor...${NC}"
            setup_windows
            echo -e "${GREEN}✓ Windows hazır! Web UI: http://localhost:3040, RDP: localhost:3041${NC}"
            ;;
        8)
            echo -e "${GREEN}🍎 macOS Sandbox kuruluyor...${NC}"
            setup_macos
            echo -e "${GREEN}✓ macOS hazır! Web UI: http://localhost:3050, VNC: localhost:3051${NC}"
            ;;
        9)
            echo -e "${GREEN}🚀 Tüm sandbox'lar kuruluyor...${NC}"
            cd sandbox-chromium && docker-compose up -d && cd ..
            setup_code_server
            setup_webtop_with_antivirus
            cd sandbox-libreoffice && docker-compose up -d && cd ..
            setup_jupyter
            setup_antivirus
            setup_windows
            setup_macos
            echo -e "${GREEN}✓ Chromium: https://localhost:3001${NC}"
            echo -e "${GREEN}✓ Code Server: http://localhost:8443${NC}"
            echo -e "${GREEN}✓ Webtop + ClamAV: http://localhost:3010${NC}"
            echo -e "${GREEN}✓ LibreOffice: http://localhost:3020${NC}"
            echo -e "${GREEN}✓ Jupyter: http://localhost:8888${NC}"
            echo -e "${GREEN}✓ Antivirus: http://localhost:3031${NC}"
            echo -e "${GREEN}✓ Windows: http://localhost:3040 (RDP: 3041)${NC}"
            echo -e "${GREEN}✓ macOS: http://localhost:3050 (VNC: 3051)${NC}"
            ;;
        10)
            cleanup_menu
            ;;
        11)
            echo -e "${YELLOW}👋 Çıkılıyor...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Geçersiz seçim!${NC}"
            select_sandbox
            ;;
    esac
}

# Code Server kurulum fonksiyonu
setup_code_server() {
    echo -e "${YELLOW}🔐 Code Server için şifre belirleme${NC}"
    read -s -p "Code Server şifresi girin (boş bırakırsanız 'admin123' kullanılır): " user_password
    echo
    
    if [ -z "$user_password" ]; then
        user_password="admin123"
        echo -e "${YELLOW}Varsayılan şifre kullanılıyor: admin123${NC}"
    fi
    
    # docker-compose.yml dosyasında şifreyi güncelle
    cd sandbox-code-server
    sed -i.bak "s/PASSWORD=degistir-bunu/PASSWORD=$user_password/" docker-compose.yml
    docker-compose up -d
    echo -e "${GREEN}✓ Şifreniz: $user_password${NC}"
    cd ..
}

# Jupyter kurulum fonksiyonu
setup_jupyter() {
    echo -e "${YELLOW}🔐 Jupyter için token belirleme${NC}"
    read -s -p "Jupyter token girin (boş bırakırsanız 'admin123' kullanılır): " user_token
    echo
    
    if [ -z "$user_token" ]; then
        user_token="admin123"
        echo -e "${YELLOW}Varsayılan token kullanılıyor: admin123${NC}"
    fi
    
    # docker-compose.yml dosyasında token'ı güncelle
    cd sandbox-jupyter
    sed -i.bak "s/JUPYTER_TOKEN=degistir-bunu/JUPYTER_TOKEN=$user_token/g" docker-compose.yml
    sed -i.bak "s/--NotebookApp.token='degistir-bunu'/--NotebookApp.token='$user_token'/g" docker-compose.yml
    docker-compose up -d
    echo -e "${GREEN}✓ Token'ınız: $user_token${NC}"
    cd ..
}

# Webtop + ClamAV kurulum fonksiyonu
setup_webtop_with_antivirus() {
    echo -e "${YELLOW}🦠 Webtop + ClamAV virüs tarayıcısı kuruluyor...${NC}"
    
    # Webtop container'ını başlat
    cd sandbox-webtop
    docker-compose up -d
    
    # Container'ın tamamen başlamasını bekle
    echo -e "${YELLOW}⏳ Webtop'un başlaması bekleniyor...${NC}"
    sleep 15
    
    # ClamAV kur (Alpine Linux için)
    echo -e "${YELLOW}🔧 ClamAV virüs tarayıcısı kuruluyor...${NC}"
    docker exec sandbox-webtop apk update
    docker exec sandbox-webtop apk add clamav clamav-daemon freshclam
    
    # ClamAV database güncelle
    echo -e "${YELLOW}📡 Virüs veritabanı güncelleniyor...${NC}"
    docker exec sandbox-webtop freshclam
    
    # Test dosyası oluştur
    docker exec sandbox-webtop sh -c 'echo "ClamAV kuruldu! Test için: clamscan --version" > /config/Desktop/ClamAV-Test.txt'
    
    echo -e "${GREEN}✅ ClamAV başarıyla kuruldu!${NC}"
    echo -e "${BLUE}💡 Test için: Terminal açıp 'clamscan --version' yazın${NC}"
    
    cd ..
}

# Antivirus kurulum fonksiyonu
setup_antivirus() {
    echo -e "${YELLOW}🦠 İzole ClamAV Antivirus Scanner kuruluyor...${NC}"
    
    # Antivirus container'ını başlat
    cd sandbox-antivirus
    docker-compose up -d
    
    # Container'ın tamamen başlamasını bekle
    echo -e "${BLUE}💡 Web UI hemen kullanılabilir: http://localhost:3031${NC}"
    echo -e "${YELLOW}⏳ Alpine Linux + ClamAV kurulumu bekleniyor...${NC}"
    echo -e "${YELLOW}   (Paket kurulumu ve virus database indirimi, 3-5 dakika sürebilir)${NC}"
    
    # Alpine Linux ClamAV kurulum sürecini bekle
    local max_wait=300  # 5 dakika
    local waited=0
    local interval=10
    
    while [ $waited -lt $max_wait ]; do
        # ClamAV kurulup çalıştığını kontrol et (clamscan komutu kullanıyor)
        if docker exec sandbox-antivirus clamscan --version &>/dev/null; then
            echo -e "${GREEN}✓ ClamAV scanner hazır!${NC}"
            break
        fi
        
        # İlerleme göstergesi
        echo -e "${YELLOW}⏳ Kurulum devam ediyor... ($waited/$max_wait saniye)${NC}"
        sleep $interval
        waited=$((waited + interval))
    done
    
    # Test dosyası oluştur (container içinde)
    echo -e "${YELLOW}🔧 Test virüs dosyası oluşturuluyor...${NC}"
    docker exec sandbox-antivirus sh -c "mkdir -p /tmp/scan && echo 'X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*' > /tmp/scan/eicar-test.txt" 2>/dev/null
    
    # Test tarama
    echo -e "${YELLOW}🔍 Test tarama yapılıyor...${NC}"
    if docker exec sandbox-antivirus clamscan /tmp/scan/eicar-test.txt 2>/dev/null | grep -q "FOUND"; then
        echo -e "${GREEN}✓ Virüs tespit çalışıyor! EICAR tespit edildi.${NC}"
    else
        echo -e "${YELLOW}⚠ Manuel kontrol gerekebilir: docker logs sandbox-antivirus${NC}"
    fi
    
    echo -e "${GREEN}✅ Alpine Linux ClamAV Scanner başarıyla kuruldu!${NC}"
    echo -e "${BLUE}💡 Web UI: http://localhost:3031${NC}"
    echo -e "${BLUE}🍎 TAM İZOLASYON: Apple Silicon uyumlu + Ana sistem bağlantısı YOK${NC}"
    echo -e "${BLUE}💡 Dosya kopyalama: docker cp dosya.exe sandbox-antivirus:/tmp/scan/${NC}"
    echo -e "${BLUE}💡 Manuel tarama: docker exec sandbox-antivirus clamscan /tmp/scan/dosya.exe${NC}"
    echo -e "${BLUE}💡 Tarama: docker exec sandbox-antivirus clamdscan /scan/dosya.exe${NC}"
    
    cd ..
}

# Windows kurulum fonksiyonu
setup_windows() {
    echo -e "${YELLOW}🪟 Windows Sandbox kuruluyor...${NC}"
    
    # KVM desteğini kontrol et
    if [ ! -e "/dev/kvm" ]; then
        echo -e "${RED}❌ KVM desteği bulunamadı!${NC}"
        echo -e "${YELLOW}💡 macOS'ta Docker Desktop kullanın (sınırlı destek)${NC}"
        echo -e "${YELLOW}💡 Linux'ta BIOS'ta virtualization etkinleştirin${NC}"
        read -p "Yine de devam etmek istiyor musunuz? [y/N]: " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Windows container'ını başlat
    cd sandbox-windows
    echo -e "${BLUE}💡 Windows 11 Pro kuruluyor (Türkçe)${NC}"
    echo -e "${WHITE}  • RAM: 4GB, CPU: 2 core, Disk: 64GB${NC}"
    echo -e "${WHITE}  • Username: Docker, Password: admin${NC}"
    
    docker-compose up -d
    
    echo -e "${YELLOW}⏳ Windows kurulumu başlıyor (10-30 dakika)...${NC}"
    echo -e "${GREEN}✅ Windows Sandbox başlatıldı!${NC}"
    echo -e "${BLUE}💡 Web UI: http://localhost:3040${NC}"
    echo -e "${BLUE}💡 RDP: localhost:3041 (Docker/admin)${NC}"
    
    cd ..
}

# macOS kurulum fonksiyonu
setup_macos() {
    echo -e "${YELLOW}🍎 macOS Sandbox kuruluyor...${NC}"
    
    # KVM desteğini kontrol et (sadece uyarı)
    if [ ! -e "/dev/kvm" ]; then
        echo -e "${YELLOW}⚠️  KVM desteği bulunamadı (macOS'ta normal)${NC}"
        echo -e "${YELLOW}💡 macOS Docker Desktop kullanıyor (sınırlı performans)${NC}"
    fi
    
    # macOS container'ını başlat
    cd sandbox-macos
    echo -e "${BLUE}💡 macOS 14 Sonoma kuruluyor${NC}"
    echo -e "${WHITE}  • RAM: 4GB, CPU: 2 core, Disk: 64GB${NC}"
    echo -e "${WHITE}  • Web UI: 3050, VNC: 3051/3052${NC}"
    
    docker-compose up -d
    
    echo -e "${YELLOW}⏳ macOS kurulumu başlıyor (30-60 dakika)...${NC}"
    echo -e "${GREEN}✅ macOS Sandbox başlatıldı!${NC}"
    echo -e "${BLUE}💡 Web UI: http://localhost:3050${NC}"
    echo -e "${BLUE}💡 VNC: localhost:3051${NC}"
    echo -e "${YELLOW}📋 Kurulum: Recovery → Disk Utility → Format (APFS) → Reinstall macOS${NC}"
    
    cd ..
}

# Temizlik menüsü
cleanup_menu() {
    echo -e "${RED}🗑️  Sandbox Temizlik Menüsü${NC}"
    echo "1) Sadece Container'ları Durdur (veriler korunur)"
    echo "2) Container'ları + Verileri Sil (sandbox sıfırla)"
    echo "3) Container'ları + Image'ları + Verileri Sil (tam temizlik)"
    echo "4) Ana Menüye Dön"
    
    read -p "Temizlik seviyesini seçin [1-4]: " cleanup_choice
    
    case $cleanup_choice in
        1)
            stop_containers
            ;;
        2)
            stop_and_remove_containers
            ;;
        3)
            full_cleanup
            ;;
        4)
            select_sandbox
            ;;
        *)
            echo -e "${RED}❌ Geçersiz seçim!${NC}"
            cleanup_menu
            ;;
    esac
}

# Container'ları durdur
stop_containers() {
    echo -e "${YELLOW}⏹️  Container'lar durduruluyor...${NC}"
    
    if [ -d "sandbox-chromium" ]; then
        cd sandbox-chromium && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Chromium container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-code-server" ]; then
        cd sandbox-code-server && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Code Server container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-webtop" ]; then
        cd sandbox-webtop && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Webtop container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-libreoffice" ]; then
        cd sandbox-libreoffice && docker-compose stop && cd ..
        echo -e "${GREEN}✓ LibreOffice container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-jupyter" ]; then
        cd sandbox-jupyter && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Jupyter container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-antivirus" ]; then
        cd sandbox-antivirus && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Antivirus container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-windows" ]; then
        cd sandbox-windows && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Windows container'ı durduruldu${NC}"
    fi
    
    if [ -d "sandbox-macos" ]; then
        cd sandbox-macos && docker-compose stop && cd ..
        echo -e "${GREEN}✓ macOS container'ı durduruldu${NC}"
    fi
    
    echo -e "${GREEN}🎉 Tüm container'lar durduruldu!${NC}"
    read -p "Ana menüye dönmek için Enter'a basın..."
    select_sandbox
}

# Container'ları durdur ve sil
stop_and_remove_containers() {
    echo -e "${YELLOW}🗑️  Container'lar ve veriler siliniyor...${NC}"
    
    if [ -d "sandbox-chromium" ]; then
        cd sandbox-chromium && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Chromium container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-code-server" ]; then
        cd sandbox-code-server && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Code Server container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-webtop" ]; then
        cd sandbox-webtop && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Webtop container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-libreoffice" ]; then
        cd sandbox-libreoffice && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ LibreOffice container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-jupyter" ]; then
        cd sandbox-jupyter && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Jupyter container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-antivirus" ]; then
        cd sandbox-antivirus && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Antivirus container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-windows" ]; then
        cd sandbox-windows && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ Windows container'ı ve verileri silindi${NC}"
    fi
    
    if [ -d "sandbox-macos" ]; then
        cd sandbox-macos && docker-compose down -v && cd ..
        echo -e "${GREEN}✓ macOS container'ı ve verileri silindi${NC}"
    fi
    
    echo -e "${GREEN}🎉 Tüm container'lar ve veriler silindi! (Temiz sandbox)${NC}"
    read -p "Ana menüye dönmek için Enter'a basın..."
    select_sandbox
}

# Tam temizlik (container + image)
full_cleanup() {
    echo -e "${RED}⚠️  TAM TEMİZLİK UYARISI!${NC}"
    echo -e "${YELLOW}Bu işlem şunları silecek:${NC}"
    echo "• Tüm sandbox container'ları"
    echo "• Tüm sandbox image'ları"
    echo "• Volume'ları (veriler kaybolacak!)"
    echo
    read -p "Emin misiniz? (yes/no): " confirm
    
    if [[ $confirm == "yes" || $confirm == "y" || $confirm == "Y" ]]; then
        echo -e "${RED}🔥 Tam temizlik başlıyor...${NC}"
        
        # Container'ları durdur ve sil
        if [ -d "sandbox-chromium" ]; then
            cd sandbox-chromium && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-code-server" ]; then
            cd sandbox-code-server && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-webtop" ]; then
            cd sandbox-webtop && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-libreoffice" ]; then
            cd sandbox-libreoffice && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-jupyter" ]; then
            cd sandbox-jupyter && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-antivirus" ]; then
            cd sandbox-antivirus && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-windows" ]; then
            cd sandbox-windows && docker-compose down -v && cd ..
        fi
        
        if [ -d "sandbox-macos" ]; then
            cd sandbox-macos && docker-compose down -v && cd ..
        fi
        
        # Image'ları sil
        echo -e "${YELLOW}📦 Image'lar siliniyor...${NC}"
        docker rmi lscr.io/linuxserver/chromium:5f5dd27e-ls102 2>/dev/null || true
        docker rmi lscr.io/linuxserver/code-server:latest 2>/dev/null || true
        docker rmi lscr.io/linuxserver/webtop:latest 2>/dev/null || true
        docker rmi lscr.io/linuxserver/libreoffice:latest 2>/dev/null || true
        docker rmi jupyter/datascience-notebook:latest 2>/dev/null || true
        docker rmi alpine:latest 2>/dev/null || true
        docker rmi nginx:alpine 2>/dev/null || true
        docker rmi dockurr/windows:latest 2>/dev/null || true
        docker rmi dockurr/macos:latest 2>/dev/null || true
        
        # Kullanılmayan volume'ları temizle
        docker volume prune -f 2>/dev/null || true
        
        echo -e "${GREEN}🎉 Tam temizlik tamamlandı!${NC}"
        echo -e "${BLUE}💡 Yeni kurulum yapmak için tekrar script'i çalıştırabilirsiniz${NC}"
        
    else
        echo -e "${GREEN}✅ Temizlik iptal edildi${NC}"
    fi
    
    read -p "Ana menüye dönmek için Enter'a basın..."
    select_sandbox
}

# Ana çalışma fonksiyonu
main() {
    echo -e "${BLUE}🔍 Docker Desktop kontrol ediliyor...${NC}"
    
    if check_docker; then
        echo -e "${GREEN}Docker Desktop hazır!${NC}"
    else
        echo -e "${YELLOW}Docker Desktop kurulumu gerekli${NC}"
        read -p "Docker Desktop'ı kurmak istiyor musunuz? [y/N]: " install_choice
        
        if [[ $install_choice =~ ^[Yy]$ ]]; then
            install_docker
            
            echo -e "${YELLOW}⏳ Docker Desktop'ın başlatılması bekleniyor...${NC}"
            sleep 10
            
            if check_docker; then
                echo -e "${GREEN}✓ Docker Desktop başarıyla kuruldu ve çalışıyor${NC}"
            else
                echo -e "${RED}❌ Docker Desktop kurulumu tamamlanamadı${NC}"
                echo "Lütfen manuel olarak Docker Desktop'ı başlatın ve scripti yeniden çalıştırın"
                exit 1
            fi
        else
            echo -e "${RED}❌ Docker Desktop kurulumu iptal edildi${NC}"
            exit 1
        fi
    fi
    
    select_sandbox
}

# Script başlat
main