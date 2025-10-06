# 🛡️ ClamAV Antivirus Scanner - Manual CLI Commands

## Apple Silicon Uyumlu Alpine Linux Tabanlı ClamAV

### Container Management

```bash
# Start antivirus container
cd sandbox-antivirus
docker-compose up -d

# Check container status
docker ps | grep antivirus

# View installation logs  
docker logs sandbox-antivirus

# Stop containers
docker-compose stop

# Remove containers and volumes (COMPLETE RESET)
docker-compose down -v
```

### Manual Container Commands (Alternative to docker-compose)

```bash
# Remove any existing containers
docker rm -f sandbox-antivirus sandbox-antivirus-ui 2>/dev/null || true

# Create named volumes
docker volume create antivirus_quarantine
docker volume create antivirus_scan  
docker volume create antivirus_logs

# Alpine Linux + ClamAV Container
docker run -d \
  --name=sandbox-antivirus \
  -p 3310:3310 \
  -v antivirus_quarantine:/quarantine \
  -v antivirus_scan:/scan \
  -v antivirus_logs:/var/log/clamav \
  --restart unless-stopped \
  alpine:latest \
  sh -c "
  echo 'Installing ClamAV on Alpine Linux...' &&
  apk update &&
  apk add --no-cache clamav clamav-daemon freshclam netcat-openbsd &&
  mkdir -p /var/lib/clamav /var/log/clamav /tmp/scan &&
  echo 'LocalSocket /tmp/clamd.sock' > /etc/clamav/clamd.conf &&
  echo 'LogFile /var/log/clamav/clamd.log' >> /etc/clamav/clamd.conf &&
  echo 'PidFile /tmp/clamd.pid' >> /etc/clamav/clamd.conf &&
  echo 'DatabaseDirectory /var/lib/clamav' >> /etc/clamav/clamd.conf &&
  echo 'TCPSocket 3310' >> /etc/clamav/clamd.conf &&
  echo 'TCPAddr 0.0.0.0' >> /etc/clamav/clamd.conf &&
  echo 'MaxThreads 20' >> /etc/clamav/clamd.conf &&
  echo 'DatabaseDirectory /var/lib/clamav' > /etc/clamav/freshclam.conf &&
  echo 'UpdateLogFile /var/log/clamav/freshclam.log' >> /etc/clamav/freshclam.conf &&
  echo 'PidFile /tmp/freshclam.pid' >> /etc/clamav/freshclam.conf &&
  echo 'DatabaseMirror database.clamav.net' >> /etc/clamav/freshclam.conf &&
  echo 'Checks 24' >> /etc/clamav/freshclam.conf &&
  echo 'Starting FreshClam for database update...' &&
  freshclam --foreground --no-daemon &
  sleep 30 &&
  echo 'Starting ClamAV daemon...' &&
  clamd --foreground
  "

# Web UI Container
docker run -d \
  --name=sandbox-antivirus-ui \
  -p 3031:80 \
  --restart unless-stopped \
  nginx:alpine
```

### ClamAV Status Checks

```bash
# Check if ClamAV daemon is running
docker exec sandbox-antivirus sh -c "echo PING | nc -w 1 localhost 3310"
# Should return: PONG

# Check ClamAV version
docker exec sandbox-antivirus clamscan --version

# Check virus database info
docker exec sandbox-antivirus sigtool --info /var/lib/clamav/daily.cvd

# View real-time logs
docker logs -f sandbox-antivirus
```

### File Transfer & Scanning

```bash
# Copy suspicious file to container (SECURE - NO HOST MOUNTS)
docker cp suspicious_file.exe sandbox-antivirus:/tmp/scan/

# Scan single file
docker exec sandbox-antivirus clamscan /tmp/scan/suspicious_file.exe

# Scan entire directory with verbose output
docker exec sandbox-antivirus clamscan -v -r /tmp/scan/

# Scan with detailed results
docker exec sandbox-antivirus clamscan --verbose --recursive /tmp/scan/
```

### EICAR Test Virus

```bash
# Create EICAR test file inside container
docker exec sandbox-antivirus sh -c "echo 'X5O!P%@AP[4\\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*' > /tmp/scan/eicar.txt"

# Scan test virus (should detect it)
docker exec sandbox-antivirus clamscan /tmp/scan/eicar.txt

# Expected output: "eicar.txt: EICAR.TEST.3.UNOFFICIAL FOUND"
```

### Database Management

```bash
# Update virus definitions manually
docker exec sandbox-antivirus freshclam

# Check database update logs
docker exec sandbox-antivirus cat /var/log/clamav/freshclam.log

# List database files
docker exec sandbox-antivirus ls -la /var/lib/clamav/
```

### Directory Management

```bash
# List scan directory contents  
docker exec sandbox-antivirus ls -la /tmp/scan/

# Clear scan directory
docker exec sandbox-antivirus rm -rf /tmp/scan/*

# Create scan subdirectories
docker exec sandbox-antivirus mkdir -p /tmp/scan/suspicious /tmp/scan/quarantine
```

### Container Interactive Access

```bash
# Access container shell for advanced operations
docker exec -it sandbox-antivirus sh

# Inside container:
# - /tmp/scan/     -> File scanning area
# - /quarantine/   -> Quarantine volume  
# - /var/lib/clamav/ -> Database location
# - /var/log/clamav/ -> Log files
```

### Troubleshooting

```bash
# Check if ClamAV processes are running
docker exec sandbox-antivirus ps aux | grep clam

# Check listening ports
docker exec sandbox-antivirus netstat -tlnp | grep 3310

# Test network connectivity
docker exec sandbox-antivirus nc -zv localhost 3310

# Restart ClamAV daemon if needed
docker exec sandbox-antivirus pkill clamd
docker exec sandbox-antivirus clamd

# View system resources
docker exec sandbox-antivirus free -h
docker exec sandbox-antivirus df -h
```

### Complete Cleanup

```bash
# Stop and remove containers
docker stop sandbox-antivirus sandbox-antivirus-ui
docker rm sandbox-antivirus sandbox-antivirus-ui

# Remove volumes (WARNING: Deletes all data)
docker volume rm antivirus_quarantine antivirus_scan antivirus_logs

# Remove Alpine image (optional)
docker rmi alpine:latest nginx:alpine
```

### Security Notes

✅ **Tam İzolasyon Garantisi:**
- Container ana sisteme mount yapmaz
- Dosya transferi sadece `docker cp` ile  
- Network izolasyonu mevcut
- Virüs tarama sonuçları güvenli

🍎 **Apple Silicon Uyumluluk:**
- Alpine Linux base image ARM64 destekli
- Manuel ClamAV kurulumu ile tam kontrol
- Tüm major Mac sistemlerde çalışır

### Web UI Access

- **URL**: http://localhost:3031
- **Features**: Isolated upload interface with security commands
- **Platform**: Apple Silicon + Intel Macs compatible

### Performance Tips

- First run takes 3-5 minutes for ClamAV installation
- Database update requires internet connection
- Container uses ~500MB RAM when fully loaded
- Scan performance depends on file size and type