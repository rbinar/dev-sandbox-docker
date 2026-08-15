# AI Coding Harness Sandbox

Tek bir container içinde 5 AI coding harness'ı (Claude Code, Codex, Antigravity/agy,
OpenCode, GitHub Copilot) bir araya getirir. Her harness kendi web terminalinde çalışır;
tarayıcıdan açılan bir picker sayfasından hangisini kullanacağını seçersin.

## Ne İçerir?

- **Picker (web arayüzü)**: `http://localhost:3060` — sekmelerden bir harness seç, terminal
  aynı sayfada iframe içinde açılır. Sekmedeki yeşil nokta harness'ın imajda kurulu olduğunu
  gösterir.
- **5 harness, her biri kendi ttyd web terminalinde**:

  | Harness | Port | Komut |
  |---|---|---|
  | Claude Code | 3061 | `claude` |
  | Codex | 3062 | `codex` |
  | Antigravity (agy) | 3063 | `agy` |
  | OpenCode | 3064 | `opencode` |
  | GitHub Copilot | 3065 | `copilot` |

## Kurulum

```bash
cd sandbox-harness
docker-compose up -d --build
```

İlk derleme (5 harness'ın kurulumu dahil) birkaç dakika sürer.

## Kullanım

1. Tarayıcıda [`http://localhost:3060`](http://localhost:3060) aç.
2. Üstteki sekmelerden bir harness seç — terminal aynı sayfada açılır.
3. Harness kurulu değilse terminalde kurulum komutu yazar; kuruluysa doğrudan başlar.

## Kimlik Doğrulama

Her harness'a **container içinde bir kez** login olman gerekir. Login bilgileri
`harness-home` volume'ünde kalıcıdır — bir daha login olman gerekmez.

**Tasarım kararı**: Host'undaki `~/.claude`, `~/.codex` gibi dizinler container'a MOUNT
EDİLMEZ. Bu bilinçlidir — sandbox'ın amacı zaten host kimlik bilgilerini container'dan
izole tutmaktır.

Her harness'ın terminalinde şu login ipucu gösterilir:

| Harness | Login ipucu |
|---|---|
| Claude Code | `/login` (tarayıcıda açılan sayfadaki kodu buraya yapıştır) |
| Codex | `codex login` ya da `CODEX_API_KEY` ortam değişkeni |
| Antigravity (agy) | `agy auth login` (Google hesabı) |
| OpenCode | OpenRouter API anahtarı ister: `opencode auth login` |
| GitHub Copilot | GitHub hesabı ister: `/login` ya da `gh auth login` |

Bir harness çıkarsa (login yarıda kalsa da) terminal kapanmaz, kabuğa düşer; tekrar
başlatmak için harness komutunu elle çalıştırman yeterli.

## Volume'ler

- **`harness-home`** (`/home/dev`) — login bilgileri ve harness ayarları. Kalıcıdır.
- **`harness-work`** (`/home/dev/work`) — üzerinde çalışılan dosyalar.

İkisi ayrı volume: birini silip diğerini koruyabilirsin (örn. login'i koruyup workspace'i
sıfırlamak, ya da tersi).

## Güvenlik

**ttyd kimlik doğrulaması olmadan kabuk verir.** Bir terminal portuna ulaşabilen herkes
container içinde komut çalıştırabilir — ve orada senin login olduğun AI hesapların durur.
Bu yüzden `docker-compose.yml`'de altı portun tamamı `127.0.0.1`'e bağlıdır:

```yaml
ports:
  - "127.0.0.1:3060:3060"   # sadece bu makineden erişilebilir
```

Bu satırlardan `127.0.0.1:` önekini kaldırmak (ya da `0.0.0.0` yazmak) container'ı
ağdaki **herkese** açar. Uzaktan erişmen gerekiyorsa portu açmak yerine SSH tüneli kullan:

```bash
ssh -L 3060:127.0.0.1:3060 -L 3061:127.0.0.1:3061 kullanici@makine
```

Container root olmayan `dev` kullanıcısı olarak çalışır ve `no-new-privileges` ile
yetki yükseltmesi kapalıdır. Yine de bu bir güvenlik sınırı değil, kolaylıktır: harness'lar
container içinde keyfi kod çalıştırabilir (zaten işleri bu), o yüzden container'a host
dizini mount ederken ne verdiğini bil.

## Sık Kullanılan Komutlar

Sık kullanılan docker komutları için `docker-harness-cli.md` dosyasına bakabilirsin.
