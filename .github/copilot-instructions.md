# Dev Sandbox Docker - AI Coding Agent Instructions

## Project Overview
This is a **security-focused Docker sandbox collection** providing isolated development environments. The architecture consists of two main sandboxes using LinuxServer.io containers with web-based access patterns.

## Core Architecture

### Sandbox Structure
- **`sandbox-chromium/`** - Isolated Chromium browser (noVNC access on ports 3000/3001)
- **`sandbox-code-server/`** - Isolated VS Code environment (web access on port 8443)
- **`sandbox-webtop/`** - Full Linux desktop environment with ClamAV antivirus (VNC access on ports 3010/3011)
- **`sandbox-libreoffice/`** - Isolated LibreOffice suite (web access on ports 3020/3021)
- **`sandbox-jupyter/`** - Jupyter Notebook environment (web access on port 8888)
- **`sandbox-antivirus/`** - Specialized virus scanning environment with ClamAV + Web UI (web access on port 3031)
- Each sandbox has its own `docker-compose.yml` and CLI documentation

### Key Components
- **Setup Scripts**: Cross-platform automation (`setup.sh` for Unix, `setup.ps1` for Windows)
- **Docker Compose**: LinuxServer.io base images with named volumes for persistence
- **CLI Documentation**: Manual Docker commands in `docker-*-cli.md` files

## Critical Workflows

### Setup Script Architecture
The setup scripts follow a specific pattern:
1. **Docker Detection**: Check `docker --version` availability
2. **Interactive Menu**: Numbered choices for sandbox selection
3. **Password Management**: Dynamic password injection for code-server
4. **Cleanup Levels**: Stop (preserve data) → Reset (remove containers+volumes) → Full (remove images too)

**Example password injection pattern**:
```bash
sed -i.bak "s/PASSWORD=degistir-bunu/PASSWORD=$user_password/" docker-compose.yml
```

### Container Management Patterns
- **Named containers**: `sandbox-chromium`, `sandbox-code-server`, `sandbox-webtop`, `sandbox-libreoffice`, `sandbox-jupyter`, `sandbox-antivirus`
- **Named volumes**: `chromium_config`, `code_server_config`, `webtop_config`, `libreoffice_config`, `jupyter_config`, `antivirus_quarantine`
- **Standard cleanup**: `docker-compose down -v` (removes volumes)
- **Image cleanup**: Specific image removal by tag/name

## Project-Specific Conventions

### Port Assignments
- **Chromium**: 3000 (HTTP noVNC), 3001 (HTTPS noVNC)
- **Code-Server**: 8443 (HTTPS web interface)
- **Webtop**: 3010 (HTTP VNC), 3011 (HTTPS VNC)
- **LibreOffice**: 3020 (HTTP web), 3021 (HTTPS web)
- **Jupyter**: 8888 (HTTP web interface)
- **Antivirus**: 3031 (HTTP Web UI), 3030 (ClamAV daemon)

### Volume Strategy
Named volumes for persistent configuration:
```yaml
volumes:
  - chromium_config:/config  # or code_server_config:/config
```

### Security Patterns
- **User mapping**: `PUID=1000 PGID=1000` (standard non-root user)
- **Resource limits**: `shm_size: "2g"` for Chromium browser stability
- **Default passwords**: Changeable via setup script, default to simple values for sandbox use
- **Antivirus integration**: Webtop automatically includes ClamAV installation via setup script

### Multi-Platform Considerations
- **Bash (Unix)**: Color codes, `read -p`, conditional package managers (homebrew/apt)
- **PowerShell (Windows)**: `Write-Host` with colors, `Push-Location`/`Pop-Location`, winget/chocolatey
- **File operations**: `.bak` backup files on sed operations

## Development Patterns

### Adding New Sandboxes
1. Create `sandbox-{name}/` directory
2. Add `docker-compose.yml` with LinuxServer.io pattern
3. Create `docker-{name}-cli.md` with manual commands
4. Update both setup scripts with new menu option
5. Add cleanup logic for new containers/images

### Modifying Setup Scripts
- **Maintain parity**: Both bash and PowerShell versions must have identical functionality
- **Color consistency**: Use established color patterns (RED for errors, GREEN for success, YELLOW for warnings)
- **Menu structure**: Keep numbered choices consistent between platforms

### Docker Compose Patterns
Standard template structure:
```yaml
services:
  service-name:
    image: lscr.io/linuxserver/{image}:latest  # or specific tag
    container_name: sandbox-{name}
    restart: unless-stopped
    ports:
      - "{host-port}:{container-port}"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Istanbul
    volumes:
      - {name}_config:/config
volumes:
  {name}_config:
```

## Integration Points

### LinuxServer.io Dependencies
- **Base images**: All containers use `lscr.io/linuxserver/*` for consistency
- **Configuration persistence**: `/config` volume mount standard across all services
- **Environment variables**: Standard PUID/PGID/TZ pattern for proper permissions

### Cross-Script Communication
- **Password handling**: Setup scripts modify compose files dynamically
- **State management**: No shared state between sandboxes (intentional isolation)
- **Cleanup coordination**: Scripts handle multiple sandbox cleanup simultaneously

## Common Issues & Solutions

### Password Management
Code-server requires password update in compose file before startup. Default placeholder is `PASSWORD=degistir-bunu`.
Jupyter requires token update in compose file before startup. Default placeholder is `JUPYTER_TOKEN=degistir-bunu`.

### Volume Cleanup
Use `docker-compose down -v` to ensure complete sandbox reset. Partial cleanup (`docker-compose stop`) preserves data for development continuity.

### Platform-Specific Docker Installation
Setup scripts handle package managers: brew (macOS), apt/curl (Linux), winget/chocolatey (Windows), with fallback to manual installation instructions.