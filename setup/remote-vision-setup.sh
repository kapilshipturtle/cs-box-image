#!/bin/bash
# remote-vision-setup.sh: ON THE BOX. /opt/vision = the laptop's stock-venv for the media stage (Python 3.11, torch
# 2.14.0+cpu, open_clip 2.32.0, numpy 2.4.6, Pillow 12.3.0) + yt-dlp 2026.08.19 (the laptop's), so the CLIP scores and
# the downloads behave as on the laptop. Warms the ViT-B-32 laion2b model. Writes /opt/vast/VISION_OK.
set -euo pipefail
export HOME=/home/shipturtle
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh >/dev/null 2>&1
uv python install 3.11 >/dev/null 2>&1
uv venv -q -p 3.11 /opt/vision
uv pip install -q -p /opt/vision/bin/python --index-url https://download.pytorch.org/whl/cpu --extra-index-url https://pypi.org/simple \
  "torch==2.14.0" "open_clip_torch==2.32.0" "numpy==2.4.6" "pillow==12.3.0" "yt-dlp==2026.8.19"
ln -sf /opt/vision/bin/yt-dlp /usr/local/bin/yt-dlp
/opt/vision/bin/python -c "import open_clip;open_clip.create_model_and_transforms('ViT-B-32', pretrained='laion2b_s34b_b79k', device='cpu');print('clip ok')"
/opt/vision/bin/python -c "import open_clip,torch,numpy,PIL;print('vision packages ok')"
touch /opt/vast/VISION_OK; echo VISION_OK
