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
    echo "3) İkisini de Kur"
    echo "4) Sandbox'ları Kaldır/Temizle"
    echo "5) Çıkış"
    
    read -p "Seçiminizi yapın [1-5]: " choice
    
    case $choice in
        1)
            echo -e "${GREEN}🌐 Chromium Browser sandbox kuruluyor...${NC}"
            cd docker-chromium
            docker-compose up -d
            echo -e "${GREEN}✓ Chromium hazır! Erişim: https://localhost:3001${NC}"
            ;;
        2)
            echo -e "${GREEN}💻 VS Code Server sandbox kuruluyor...${NC}"
            setup_code_server
            echo -e "${GREEN}✓ Code Server hazır! Erişim: http://localhost:8443${NC}"
            ;;
        3)
            echo -e "${GREEN}🚀 Her iki sandbox da kuruluyor...${NC}"
            cd docker-chromium && docker-compose up -d && cd ..
            setup_code_server
            echo -e "${GREEN}✓ Chromium: https://localhost:3001${NC}"
            echo -e "${GREEN}✓ Code Server: http://localhost:8443${NC}"
            ;;
        4)
            cleanup_menu
            ;;
        5)
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
    cd docker-code-server
    sed -i.bak "s/PASSWORD=degistir-bunu/PASSWORD=$user_password/" docker-compose.yml
    docker-compose up -d
    echo -e "${GREEN}✓ Şifreniz: $user_password${NC}"
    cd ..
}

# Temizlik menüsü
cleanup_menu() {
    echo -e "${RED}🗑️  Sandbox Temizlik Menüsü${NC}"
    echo "1) Sadece Container'ları Durdur"
    echo "2) Container'ları Durdur + Sil"
    echo "3) Container'ları + Image'ları Sil (Tam Temizlik)"
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
    
    if [ -d "docker-chromium" ]; then
        cd docker-chromium && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Chromium container'ı durduruldu${NC}"
    fi
    
    if [ -d "docker-code-server" ]; then
        cd docker-code-server && docker-compose stop && cd ..
        echo -e "${GREEN}✓ Code Server container'ı durduruldu${NC}"
    fi
    
    echo -e "${GREEN}🎉 Tüm container'lar durduruldu!${NC}"
    read -p "Ana menüye dönmek için Enter'a basın..."
    select_sandbox
}

# Container'ları durdur ve sil
stop_and_remove_containers() {
    echo -e "${YELLOW}🗑️  Container'lar siliniyor...${NC}"
    
    if [ -d "docker-chromium" ]; then
        cd docker-chromium && docker-compose down && cd ..
        echo -e "${GREEN}✓ Chromium container'ı silindi${NC}"
    fi
    
    if [ -d "docker-code-server" ]; then
        cd docker-code-server && docker-compose down && cd ..
        echo -e "${GREEN}✓ Code Server container'ı silindi${NC}"
    fi
    
    echo -e "${GREEN}🎉 Tüm container'lar silindi!${NC}"
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
        if [ -d "docker-chromium" ]; then
            cd docker-chromium && docker-compose down -v && cd ..
        fi
        
        if [ -d "docker-code-server" ]; then
            cd docker-code-server && docker-compose down -v && cd ..
        fi
        
        # Image'ları sil
        echo -e "${YELLOW}📦 Image'lar siliniyor...${NC}"
        docker rmi lscr.io/linuxserver/chromium:5f5dd27e-ls102 2>/dev/null || true
        docker rmi lscr.io/linuxserver/code-server:latest 2>/dev/null || true
        
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