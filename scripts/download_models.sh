#!/bin/bash
# Download AI Models Script for PrivaVoz
# Run this script to download required AI models

set -e

MODELS_DIR="$(dirname "$0")/models"

echo "📥 Downloading PrivaVoz AI Models..."
echo "======================================"

mkdir -p "$MODELS_DIR"

# Whisper Tiny (75MB)
echo "[1/2] Downloading Whisper Tiny..."
curl -L -o "$MODELS_DIR/whisper-tiny.bin" \
  "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/whisper-tiny.bin"

# TinyLlama 1.1B Q4 (637MB)
echo "[2/2] Downloading TinyLlama 1.1B Q4..."
curl -L -o "$MODELS_DIR/tinyllama-1.1b-q4.gguf" \
  "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/tinyllama-1.1b-q4.gguf"

echo ""
echo "✅ Models downloaded successfully!"
echo "Total size: $(du -sh "$MODELS_DIR" | cut -f1)"
echo ""
echo "Models location: $MODELS_DIR/"
ls -lh "$MODELS_DIR/"