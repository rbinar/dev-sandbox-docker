#!/usr/bin/env bash
# Her harness için bir ttyd örneği + picker'ı sunan statik sunucuyu başlatır.
# Ön planda kalır; tini PID 1 olduğu için sinyaller doğru iletilir.
set -uo pipefail

WEB_ROOT=/opt/harness/web
BIN_DIR=/opt/harness/bin
PICKER_PORT="${HARNESS_PICKER_PORT:-3060}"

# ad:port:komut  — index.html'deki sekmelerle aynı sırada olmalı.
HARNESSES=(
  "claude:3061:claude"
  "codex:3062:codex"
  "antigravity:3063:agy"
  "opencode:3064:opencode"
  "copilot:3065:copilot"
)

pids=()
cleanup() {
  for p in "${pids[@]:-}"; do kill "$p" 2>/dev/null || true; done
}
trap cleanup TERM INT

echo "== AI harness sandbox =="
for entry in "${HARNESSES[@]}"; do
  name="${entry%%:*}"
  rest="${entry#*:}"
  port="${rest%%:*}"
  cmd="${rest#*:}"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  $name -> :$port  ($(command -v "$cmd"))"
  else
    # Harness kurulamamışsa terminali yine aç: içinde neden yok ve nasıl kurulur yazsın.
    echo "  $name -> :$port  (KURULU DEGIL)"
  fi

  # -W yazılabilir mod (etkileşim şart). Kimlik doğrulama yok çünkü port yalnız
  # 127.0.0.1'e bağlanıyor (docker-compose.yml); container ağa açılmıyor.
  ttyd -p "$port" -W \
       -t "titleFixed=$name" -t fontSize=15 -t 'theme={"background":"#111318"}' \
       bash -lc "HARNESS_NAME='$name' HARNESS_CMD='$cmd' $BIN_DIR/launch.sh" \
       >/dev/null 2>&1 &
  pids+=("$!")
done

echo "  picker -> :$PICKER_PORT"
node "$BIN_DIR/serve.mjs" "$PICKER_PORT" "$WEB_ROOT" &
pids+=("$!")

echo
echo "Tarayicidan ac: http://localhost:$PICKER_PORT"
echo

wait -n
cleanup
