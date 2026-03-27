# PrivaVoz AI Models

## Download Required AI Models

Since model files are too large for Git, download them separately:

### Option 1: Direct Download

```bash
# Create models directory
mkdir -p models

# Download Whisper Tiny (75MB)
curl -L -o models/whisper-tiny.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"

# Download TinyLlama 1.1B Q4 (637MB)
curl -L -o models/tinyllama-1.1b-q4.gguf "https://huggingface.co/hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0-q4_k_m.gguf"
```

### Option 2: Manual Download

1. **Whisper Tiny**: https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-tiny.bin
2. **TinyLlama**: https://huggingface.co/hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF

### Total Size: ~712MB

- whisper-tiny.bin: ~75MB
- tinyllama-1.1b-q4.gguf: ~637MB

### Integration

The app automatically loads models from the `models/` directory at startup. Models are copied to app storage on first run.

### Build Note

If building with `flutter build apk`, the models directory should contain placeholder files or be empty. The actual models will be loaded at runtime from app storage.