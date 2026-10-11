# cs-box: the Channel Studio rented-box environment (Plan Freedom), built ONCE so a vast.ai box starts working in ~1-2 min
# instead of installing for ~15. Contents: Ubuntu 20.04 (ffmpeg 4.2.7 = the laptop's, so renders match), Node 22.22.0,
# HyperFrames 0.8.92 + its pinned chrome-headless-shell, Playwright Chromium, Python 3.8 packages pinned to the laptop's,
# /opt/vision (Python 3.11: torch 2.14 cpu, open_clip 2.32, CLIP weights), textsim and yt-fast venvs. NO app code, NO keys,
# NO private fonts: those are copied to the box at rent time.
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive HOME=/home/shipturtle
COPY setup/ /opt/vast/
RUN mkdir -p /home/shipturtle /opt/vast && apt-get update -qq && apt-get install -y -qq --no-install-recommends openssh-server >/dev/null \
 && bash /opt/vast/remote-setup.sh && touch /opt/vast/SETUP_OK \
 && bash /opt/vast/remote-vision-setup.sh \
 && bash /opt/vast/remote-freedom-setup.sh \
 && touch /opt/vast/IMAGE_OK && rm -rf /var/lib/apt/lists/* /root/.cache/pip /home/shipturtle/.cache/pip /tmp/*
LABEL org.opencontainers.image.source=https://github.com/kapilshipturtle/cs-box-image
