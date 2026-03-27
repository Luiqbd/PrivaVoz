# PrivaVoz AI Models

## ⚠️ Important - Models Not in Git

Due to GitHub's 100MB file size limit, AI models cannot be stored in the repository.
**You must download them separately.**

## Quick Download

### Option 1: Python Script
```bash
cd scripts
python3 download_models.py
```

### Option 2: Shell Script
```bash
bash scripts/download_models.sh
```

### Option 3: Manual Download

1. **Whisper Tiny** (75MB):
   ```bash
   curl -L -o models/whisper-tiny.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
   ```

2. **TinyLlama 1.1B Q4** (637MB):
   ```bash
   curl -L -o models/tinyllama-1.1b-q4.gguf "https://huggingface.co/hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0-q4_k_m.gguf"
   ```

## Models Summary

| Model | File | Size | Purpose |
|-------|------|------|---------|
| Whisper Tiny | `whisper-tiny.bin` | 75MB | Transcription + Karaoke |
| TinyLlama 1.1B | `tinyllama-1.1b-q4.gguf` | 637MB | Summaries |
| **Total** | | **712MB** | |

## First Run

On first app launch, models are automatically copied from `assets/models/` to app storage.
Make sure the models folder contains the model files before building!