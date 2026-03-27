# PrivaVoz AI Models

## ⬇️ Download AI Models (Required)

Download the AI models from GitHub Releases:

### Option 1: Direct Download
```bash
# Whisper Tiny (75MB)
curl -L -o models/whisper-tiny.bin "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/whisper-tiny.bin"

# TinyLlama 1.1B Q4 (637MB)
curl -L -o models/tinyllama-1.1b-q4.gguf "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/tinyllama-1.1b-q4.gguf"
```

### Option 2: Python Script
```bash
cd scripts
python3 download_models.py
```

### Option 3: Shell Script
```bash
bash scripts/download_models.sh
```

### Option 4: Manual Download
1. Go to: https://github.com/Luiqbd/PrivaVoz/releases/tag/v1.0.0-models
2. Download both files
3. Place in `models/` folder

## Models Summary

| Model | File | Size | Purpose |
|-------|------|------|---------|
| Whisper Tiny | `whisper-tiny.bin` | 75MB | Transcription + Karaoke |
| TinyLlama 1.1B | `tinyllama-1.1b-q4.gguf` | 637MB | Summaries |
| **Total** | | **712MB** | |

## First Run

On first app launch, models are automatically copied from `assets/models/` to app storage.
Make sure the models folder contains the model files before building!