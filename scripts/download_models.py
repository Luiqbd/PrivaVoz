#!/usr/bin/env python3
"""
PrivaVoz AI Models Downloader
Run this script to download required AI models for PrivaVoz app.

Usage:
    python download_models.py
"""

import os
import sys
import urllib.request
from pathlib import Path

# Configuration
MODELS = [
    {
        "name": "whisper-tiny.bin",
        "url": "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/whisper-tiny.bin",
        "size_mb": 75,
    },
    {
        "name": "tinyllama-1.1b-q4.gguf",
        "url": "https://github.com/Luiqbd/PrivaVoz/releases/download/v1.0.0-models/tinyllama-1.1b-q4.gguf",
        "size_mb": 637,
    },
]

def download_file(url: str, dest: Path, expected_mb: int):
    """Download file with progress indication"""
    print(f"\n📥 Downloading {dest.name} ({expected_mb}MB)...")
    
    def report_progress(block_num, block_size, total_size):
        if total_size > 0:
            percent = min(100, block_num * block_size / total_size * 100)
            downloaded_mb = block_num * block_size / 1024 / 1024
            sys.stdout.write(f"\r  Progress: {downloaded_mb:.1f}MB / {total_size/1024/1024:.1f}MB ({percent:.1f}%)")
            sys.stdout.flush()
    
    try:
        urllib.request.urlretrieve(url, dest, reporthook=report_progress)
        print(f"\n  ✅ Downloaded: {dest.name}")
        return True
    except Exception as e:
        print(f"\n  ❌ Error: {e}")
        return False

def main():
    # Get script directory
    script_dir = Path(__file__).parent
    models_dir = script_dir / "models"
    
    print("=" * 50)
    print("📦 PrivaVoz AI Models Downloader")
    print("=" * 50)
    
    # Create models directory
    models_dir.mkdir(exist_ok=True)
    
    # Download each model
    success_count = 0
    for model in MODELS:
        model_path = models_dir / model["name"]
        
        if model_path.exists():
            print(f"\n⏭️  Skipping {model['name']} (already exists)")
            success_count += 1
            continue
        
        if download_file(model["url"], model_path, model["size_mb"]):
            success_count += 1
    
    print("\n" + "=" * 50)
    if success_count == len(MODELS):
        print("✅ All models downloaded successfully!")
    else:
        print(f"⚠️  {success_count}/{len(MODELS)} models downloaded")
    print("=" * 50)
    
    # Show final directory contents
    print(f"\n📁 Models location: {models_dir}")
    print("-" * 50)
    for f in sorted(models_dir.iterdir()):
        size_mb = f.stat().st_size / 1024 / 1024
        print(f"  {f.name}: {size_mb:.1f}MB")

if __name__ == "__main__":
    main()