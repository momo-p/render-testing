# render-testing

Container image for GPU render tests: PyTorch, diffusers, Kokoro, Blender and ffmpeg in one image.

The image holds tools only. Model weights download at run time to `/workspace/hf`, and scripts are copied to the machine per run.

Pushing a change to `Dockerfile` builds the image, runs a smoke test, and publishes it to `ghcr.io/<owner>/render-testing`.
