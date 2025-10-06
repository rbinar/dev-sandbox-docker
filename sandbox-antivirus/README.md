## Docker-Antivirus Konteynerini Başlatma

Terminalde `docker-antivirus-cli.md` içindeki komutları çalıştırarak docker-antivirus konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Container başlatıldıktan sonra:
- **ClamAV Daemon**: localhost:3310 (TCP)
- **Web UI**: [`http://localhost:3031`](http://localhost:3031) (Dosya upload & tarama)

### 🦠 **Antivirus Sandbox Özellikleri**

#### **1. Web Tabanlı Dosya Tarama:**
- Drag & drop dosya yükleme
- REST API ile toplu tarama
- Real-time tarama sonuçları
- Quarantine zone yönetimi

#### **1. Güvenli Dosya Aktarımı:**
```bash
# Ana sistemden container'a güvenli kopyalama
docker cp suspicious_file.exe sandbox-antivirus:/tmp/scan/
docker cp malware_folder/ sandbox-antivirus:/tmp/scan/

# Container'dan ana sisteme (temizlendikten sonra)
docker cp sandbox-antivirus:/tmp/scan/clean_file.txt ./
```

#### **2. İzole Virüs Tarama:**
```bash
# Tek dosya tara
docker exec sandbox-antivirus clamscan /tmp/scan/suspicious_file.exe

# Tüm dizini tara
docker exec sandbox-antivirus clamscan -r /tmp/scan/

# Detaylı tarama (verbose)
docker exec sandbox-antivirus clamscan -v -r /tmp/scan/

# Real-time logs
docker logs -f sandbox-antivirus
```

#### **3. Test Virüs Dosyası (Container İçinde):**
```bash
# Scan dizini oluştur
docker exec sandbox-antivirus mkdir -p /tmp/scan

# EICAR test virus dosyası oluştur (container içinde)
docker exec sandbox-antivirus sh -c "echo 'X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*' > /tmp/scan/eicar.txt"

# Test taraması
docker exec sandbox-antivirus clamscan /tmp/scan/eicar.txt

# Sonuç: "FOUND" çıkarsa ClamAV çalışıyor demektir
```

#### **4. Container Temizliği:**
```bash
# Sadece scan dizinini temizle
docker exec sandbox-antivirus rm -rf /tmp/scan/*

# Container'ı tamemen sıfırla
docker-compose down -v
```

#### **3. Test Etme:**
```bash
# EICAR test virus dosyası (zararsız test)
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > ./scan-input/eicar.txt

# Test taraması
docker exec sandbox-antivirus clamdscan /scan-input/eicar.txt

# Sonuç: "FOUND" çıkarsa ClamAV çalışıyor demektir
```

### 🛡️ **Güvenlik Kullanım Senaryoları**

- **Şüpheli dosya analizi**: Bilinmeyen dosyaları güvenli ortamda tarama
- **Email ek kontrolü**: Gelen email eklerini toplu tarama
- **USB/Harici disk tarama**: Harici medya güvenlik kontrolü
- **Toplu dosya tarama**: Birden fazla dosyayı otomatik tarama
- **Quarantine yönetimi**: Virüslü dosyaları izole etme
- **API entegrasyonu**: Diğer sistemlere entegre virüs tarama

### 🔍 **Test Etme:**

```bash
# EICAR test virus dosyası indir (zararsız test)
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > eicar.txt

# Dosyayı scan-input'a koy
cp eicar.txt ./scan-input/

# Web UI'da tara: http://localhost:3031
# Veya komut satırında:
docker exec sandbox-antivirus clamscan /scan-input/eicar.txt
```

### 📊 **Log Takibi:**
```bash
# Real-time log takip
docker exec sandbox-antivirus tail -f /var/log/clamav/clamd.log

# Tarama geçmişi
docker exec sandbox-antivirus cat /var/log/clamav/scan.log
```

## Kaynaklar

- [ClamAV Official Docker](https://hub.docker.com/r/clamav/clamav)
- [ClamAV REST API](https://github.com/benzino77/clamav-rest-api)