# AI coding harness sandbox — Claude Code, Codex, Antigravity, OpenCode ve
# GitHub Copilot CLI'ı tek imajda toplar, her birini tarayıcıdan erişilebilen bir
# web terminalinde sunar.
#
# Tasarım kararı: harness'lar imaja kurulur, kimlik bilgileri KURULMAZ. Container
# ilk açıldığında her harness'a kendin login olursun; oturumlar adlandırılmış bir
# volume'de kalıcıdır. Host'undaki ~/.claude, ~/.codex vb. hiçbir zaman mount
# edilmez — sandbox'ın amacı zaten bu.
FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash git curl wget ca-certificates gnupg \
      ripgrep jq less nano vim-tiny procps psmisc \
      python3 python3-pip python3-venv \
      tini unzip \
 && rm -rf /var/lib/apt/lists/*

# ttyd: shell'i HTTP üzerinden sunar. Debian bookworm paketi varsa onu kullan,
# yoksa statik release binary'sine düş (arm64 ve amd64 için ayrı asset).
RUN apt-get update \
 && (apt-get install -y --no-install-recommends ttyd \
     || (arch="$(uname -m)" \
         && curl -fsSL -o /usr/local/bin/ttyd \
              "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${arch}" \
         && chmod +x /usr/local/bin/ttyd)) \
 && rm -rf /var/lib/apt/lists/* \
 && ttyd --version

# --- Harness'lar -------------------------------------------------------------
# Her kurulum ayrı katman: biri upstream'de kırılırsa diğerleri cache'ten gelir.
# `|| true` bilinçli — bir harness kurulamazsa imaj yine de ayağa kalkmalı, eksik
# olan terminalinde raporlanır (entrypoint her harness'ı PATH'te doğrular).
RUN npm install -g @anthropic-ai/claude-code || true
RUN npm install -g @openai/codex            || true
RUN npm install -g opencode-ai              || true
RUN npm install -g @github/copilot          || true
RUN npm cache clean --force || true

# Antigravity (agy) kendi installer'ıyla gelir ve $HOME'a yazar; root'un
# HOME'una kurup sonuçtaki binary'i /usr/local/bin'e alıyoruz ki her kullanıcı
# görebilsin.
RUN (curl -fsSL https://antigravity.google/cli/install.sh | bash || true) \
 && for p in /root/.antigravity/bin/agy /root/.local/bin/agy /usr/local/bin/agy; do \
      [ -x "$p" ] && cp "$p" /usr/local/bin/agy && break; \
    done; true

# --- Kullanıcı ---------------------------------------------------------------
# Root olmayan kullanıcı: container içindeki hiçbir şey host'ta root taklidi yapamasın.
RUN useradd -m -s /bin/bash -u 1001 dev
WORKDIR /home/dev

COPY --chown=dev:dev web/    /opt/harness/web/
COPY --chown=dev:dev bin/    /opt/harness/bin/
RUN chmod +x /opt/harness/bin/*

USER dev
RUN mkdir -p /home/dev/work \
 && git config --global user.email dev@sandbox.invalid \
 && git config --global user.name  "sandbox dev" \
 && git config --global init.defaultBranch main
ENV PATH="/home/dev/.local/bin:${PATH}"

# 3060 picker (statik), 3061-3065 harness başına bir web terminali
EXPOSE 3060 3061 3062 3063 3064 3065

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/harness/bin/entrypoint.sh"]
