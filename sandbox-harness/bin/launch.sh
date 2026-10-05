#!/usr/bin/env bash
# Bir web terminalinin içinde çalışan oturum. Harness'ı başlatır; harness çıkınca
# kabuğa düşer, böylece login akışı yarıda kalırsa terminal kapanmaz.
set -uo pipefail

NAME="${HARNESS_NAME:-harness}"
CMD="${HARNESS_CMD:-bash}"

declare -A INSTALL_HINT=(
  [claude]="npm i -g @anthropic-ai/claude-code"
  [codex]="npm i -g @openai/codex"
  [agy]="curl -fsSL https://antigravity.google/cli/install.sh | bash"
  [opencode]="npm i -g opencode-ai"
  [copilot]="npm i -g @github/copilot"
)

declare -A LOGIN_HINT=(
  [claude]="Acilinca:  /login   (tarayicida acilan sayfadaki kodu buraya yapistir)"
  [codex]="Acilinca:  codex login   ya da  CODEX_API_KEY ortam degiskeni"
  [agy]="Acilinca agy Google girisine yonlendirir (ayri bir auth komutu yok)"
  [opencode]="OpenRouter API anahtari ister: opencode auth login"
  [copilot]="Kabukta:  copilot login --device-code   (uygulama ici /login token'i burada saklamiyor)"
)

cd "$HOME/work" 2>/dev/null || cd "$HOME"

echo "=============================================="
echo "  $NAME"
echo "=============================================="
echo

if ! command -v "$CMD" >/dev/null 2>&1; then
  echo "  Bu harness imajda KURULU DEGIL."
  echo "  Kurmak icin:"
  echo "      ${INSTALL_HINT[$CMD]:-<kurulum komutu bilinmiyor>}"
  echo
  echo "  Kurduktan sonra bu sekmeyi yenile."
  echo
  exec bash
fi

echo "  ${LOGIN_HINT[$CMD]:-}"
echo "  Calisma dizini: $(pwd)"
echo "  Oturum bilgileri volume'de kalici — bir kez login yeter."
echo
echo "  ($NAME kapaninca kabuga dusersin; tekrar baslatmak icin: $CMD)"
echo

"$CMD"
rc=$?
echo
echo "[$NAME cikti, kod=$rc — kabuktasin. Tekrar baslat: $CMD]"
exec bash
