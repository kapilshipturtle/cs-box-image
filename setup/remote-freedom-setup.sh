#!/bin/bash
# ON THE BOX after remote-setup.sh + remote-vision-setup.sh: the rest of the laptop's Python world for EVERY stage, same
# versions (system python 3.8: opencv 4.10, spaCy 3.7.5 + en_core_web_sm 3.7.1, yt_dlp 2024.10.22, torch 2.1.1 + timm +
# transformers 4.46.3 for the detail finder; textsim-venv: sentence-transformers 3.2.1 / torch 2.4.1; yt-fast-venv 3.12),
# the claude stand-in, the stock-venv link. Writes /opt/vast/FREEDOM_OK.
set -euo pipefail
export HOME=/home/shipturtle
python3 -m pip install -q --no-cache-dir "pip==24.0" "setuptools<70" wheel   # 20.04 pip 20 cannot use manylinux_2_17 wheels: spaCy deps tried to compile (2026-10-11)
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq g++ python3-dev python3-venv >/dev/null   # cymem 2.0.11 / murmurhash 1.0.15 have no py3.8 wheel: built here, as on the laptop
P="python3 -m pip install -q --no-cache-dir"
$P "blis==0.7.11" "catalogue==2.0.10" "cloudpathlib==0.20.0" "confection==0.1.5" "cymem==2.0.11" "langcodes==3.4.1" "murmurhash==1.0.15" "preshed==3.0.12" "pydantic==2.10.6" "spacy-legacy==3.0.12" "spacy-loggers==1.0.5" "srsly==2.4.8" "thinc==8.2.5" "typer==0.20.1" "wasabi==1.1.3" "weasel==0.4.3"
$P "opencv-python-headless==4.10.0.84" "spacy==3.7.5" "yt-dlp==2024.10.22" "transformers==4.46.3" "timm==1.0.29" requests
$P --index-url https://download.pytorch.org/whl/cpu "torch==2.1.1" "torchvision==0.16.1"
$P "https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl"
mkdir -p $HOME/.hyperframes-tools $HOME/.local/bin
python3 -m venv $HOME/.hyperframes-tools/textsim-venv
$HOME/.hyperframes-tools/textsim-venv/bin/pip install -q --no-cache-dir "numpy==1.24.4" "sentence-transformers==3.2.1" "transformers==4.46.3" --extra-index-url https://download.pytorch.org/whl/cpu "torch==2.4.1+cpu"
uv venv -q -p 3.12 $HOME/.hyperframes-tools/yt-fast-venv && uv pip install -q -p $HOME/.hyperframes-tools/yt-fast-venv/bin/python "yt-dlp==2026.8.19"
ln -sfn /opt/vision $HOME/.hyperframes-tools/stock-venv
ln -sf /usr/local/bin/yt-dlp $HOME/.local/bin/yt-dlp
install -m 755 /opt/vast/claude-shim.py /usr/local/bin/claude
[ -d $HOME/channel-studio/pipeline ] && (cd $HOME/channel-studio && python3 -c "import cv2,spacy,torch,yt_dlp;print('packages ok')") || python3 -c "import cv2,spacy,torch,yt_dlp;print('packages ok')"
touch /opt/vast/FREEDOM_OK; echo FREEDOM_OK
