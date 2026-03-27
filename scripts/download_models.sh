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
  "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"

# TinyLlama 1.1B Q4 (637MB)
echo "[2/2] Downloading TinyLlama 1.1B Q4..."
curl -L -o "$MODELS_DIR/tinyllama-1.1b-q4.gguf" \
  "https://huggingface.co/hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0-q4_k_m.gguf"

echo ""
echo "✅ Models downloaded successfully!"
echo "Total size: $(du -sh "$MODELS_DIR" | cut -f1)"
echo ""
echo "Models location: $MODELS_DIR/"
ls -lh "$MODELS_DIR/"