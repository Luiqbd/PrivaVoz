# Modelos IA - Download Necessário para Build

## ⚡ ATENÇÃO - Execute antes de compilar!

Devido ao limite do GitHub (100MB), os modelos devem ser baixados ANTES do primeiro build:

```bash
# Execute este comando NA SUA MÁQUINA (com internet):
cd assets/models
curl -L -o whisper-tiny.bin "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/whisper-tiny.bin"
curl -L -o tinyllama-1.1b-q4.gguf "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/tinyllama-1.1b-q4.gguf"

# Depois compile:
flutter build apk --release

# O APK resultante funciona 100% OFFLINE!
```

## Scripts Automáticos

```bash
# Python:
python3 scripts/download_models.py

# Shell:
bash scripts/download_models.sh
```

## Modelo Já No GitHub Release

Baixe de: https://github.com/Luiqbd/PrivaVoz/releases/tag/v1.0.0-models

## Funcionamento Offline

Uma vez compilado o APK com os modelos inclusos:
- ✅ Sem internet
- ✅ Transcrição Whisper
- ✅ Resumos TinyLlama
- ✅ Tudo 100% local!