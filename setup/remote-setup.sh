#!/bin/bash
# vast.ai render test (user 2026-10-10): make an ubuntu:20.04 container match the LAPTOP for the app's build + render code:
# Ubuntu 20.04 (ffmpeg 4.2.7 / libx264 155: HyperFrames encodes with the ffmpeg on PATH, as on the laptop), Python 3.8 +
# numpy, the official Node 22.22.0 build (laptop: v22.22.0), HyperFrames 0.8.92 (fetched by npx with its pinned Chrome),
# the laptop's own fonts (staged by stage.sh into /usr/share/fonts and ~/.local/share/fonts), same paths (/home/shipturtle).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends python3 python3-pip ffmpeg unzip rsync openssh-client ca-certificates curl \
  xz-utils procps fontconfig libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 \
  libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 libx11-xcb1 libxshmfence1 >/dev/null
# the laptop's fonts: the same Ubuntu 20.04 packages (font-packages.txt, from dpkg -S on the laptop), not 373 MB uploaded;
# one package that is missing from the archive must not stop the rest
if [ -s /opt/vast/font-packages.txt ]; then
  apt-get install -y -qq --no-install-recommends $(cat /opt/vast/font-packages.txt) >/dev/null 2>&1 \
    || for p in $(cat /opt/vast/font-packages.txt); do apt-get install -y -qq --no-install-recommends "$p" >/dev/null 2>&1 || echo "font package missing: $p"; done
fi
# the laptop's exact Python packages for build / render / the page check (pipeline/pageqa.py launches Playwright's Chromium)
python3 -m pip install -q --no-cache-dir "numpy==1.24.4" "Pillow==10.1.0" "playwright==1.48.0"
HOME=/home/shipturtle python3 -m playwright install chromium >/dev/null     # the build runs with HOME=/home/shipturtle
if [ ! -x /opt/node/bin/node ]; then
  curl -fsSL https://nodejs.org/dist/v22.22.0/node-v22.22.0-linux-x64.tar.xz | tar -xJ -C /opt
  mv /opt/node-v22.22.0-linux-x64 /opt/node
fi
ln -sf /opt/node/bin/node /opt/node/bin/npm /opt/node/bin/npx /usr/local/bin/
# containers have no systemd: the render command starts with "systemd-inhibit --what=... --why=..."; pass it through
cat > /usr/local/bin/systemd-inhibit <<'SH'
#!/bin/sh
while [ $# -gt 0 ]; do case "$1" in --*) shift ;; *) break ;; esac; done
exec "$@"
SH
chmod +x /usr/local/bin/systemd-inhibit
fc-cache -f >/dev/null 2>&1 || true
cd /tmp && HOME=/home/shipturtle npx --yes hyperframes@0.8.92 --version
# HyperFrames' pinned Chrome (laptop: chrome-headless-shell 152.0.7977.30), fetched NOW so a browser problem shows here
HOME=/home/shipturtle npx --yes hyperframes@0.8.92 browser ensure
ls /home/shipturtle/.cache/hyperframes/chrome/chrome-headless-shell/
echo "setup ok: $(lsb_release -ds 2>/dev/null || head -1 /etc/os-release), $(python3 --version), node $(node --version), $(ffmpeg -version | head -1 | cut -d' ' -f1-3), $(nproc) cores, $(free -g | awk '/Mem/{print $2}') GB RAM, $(fc-list | wc -l) fonts"
