FROM runpod/pytorch:1.0.3-cu1281-torch291-ubuntu2404

ARG BLENDER_VERSION=5.2.3
ENV DEBIAN_FRONTEND=noninteractive PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg xz-utils curl rsync espeak-ng python3-venv \
        libgl1 libegl1 libxi6 libxxf86vm1 libxfixes3 libxrender1 libxkbcommon0 libsm6 libice6 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://download.blender.org/release/Blender${BLENDER_VERSION%.*}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" | tar -xJ -C /opt \
    && ln -s "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender

# Pinning torch keeps pip from replacing the build that matches the base image's CUDA.
RUN TORCH=$(python -c 'import torch; print(torch.__version__)') \
    && python -m pip install --root-user-action=ignore "torch==$TORCH" \
        "diffusers>=0.41.0" transformers accelerate ftfy sentencepiece imageio imageio-ffmpeg \
        gradio spaces peft hf_transfer

# Kokoro needs transformers<5, which conflicts with the huggingface-hub version diffusers and gradio need.
RUN python -m venv /opt/tts \
    && /opt/tts/bin/pip install torch --index-url https://download.pytorch.org/whl/cpu \
    && /opt/tts/bin/pip install kokoro soundfile "transformers<5"

# Model weights are downloaded at run time to a mounted volume, not baked into the image.
ENV HF_HOME=/workspace/hf HF_HUB_ENABLE_HF_TRANSFER=1
