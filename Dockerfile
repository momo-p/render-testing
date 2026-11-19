FROM runpod/pytorch:1.0.3-cu1281-torch291-ubuntu2404

ARG BLENDER_VERSION=5.2.3
ENV DEBIAN_FRONTEND=noninteractive PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg xz-utils curl rsync espeak-ng \
        libgl1 libegl1 libxi6 libxxf86vm1 libxfixes3 libxrender1 libxkbcommon0 libsm6 libice6 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://download.blender.org/release/Blender${BLENDER_VERSION%.*}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" | tar -xJ -C /opt \
    && ln -s "/opt/blender-${BLENDER_VERSION}-linux-x64/blender" /usr/local/bin/blender

# Pinning torch keeps pip from replacing the build that matches the base image's CUDA.
RUN TORCH=$(python -c 'import torch; print(torch.__version__)') \
    && python -m pip install --root-user-action=ignore "torch==$TORCH" \
        "diffusers>=0.41.0" "transformers<5" accelerate ftfy sentencepiece imageio imageio-ffmpeg \
        gradio spaces peft hf_transfer kokoro soundfile

# Model weights are downloaded at run time to a mounted volume, not baked into the image.
ENV HF_HOME=/workspace/hf HF_HUB_ENABLE_HF_TRANSFER=1
