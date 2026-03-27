# PrivaVoz Build Instructions

## Prerequisites

1. **Flutter SDK** (3.x or latest)
2. **Android SDK** (API 34)
3. **NDK** (26.1.10909125)

## Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/Luiqbd/PrivaVoz.git
cd PrivaVoz
flutter pub get
```

### 2. Download AI Models
```bash
# Option 1: Python script
cd scripts
python3 download_models.py

# Option 2: Manual
mkdir -p models
curl -L -o models/whisper-tiny.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
curl -L -o models/tinyllama-1.1b-q4.gguf "https://huggingface.co/hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0-q4_k_m.gguf"
```

### 3. Build Debug APK
```bash
flutter build apk --debug
```

### 4. Build Release APK
```bash
flutter build apk --release
```

## Build with Native FFI (Optional)

For full AI functionality, build with native libraries:

### Prerequisites for Native Build:
```bash
# Install NDK via Android Studio SDK Manager
# Or via command line:
sdkmanager "ndk;26.1.10909125"
```

### Build with CMake:
```bash
flutter build apk --release \
  --target-platform android-arm64 \
  -v
```

## Output Location

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Model files not found
Make sure `models/whisper-tiny.bin` and `models/tinyllama-1.1b-q4.gguf` exist before building.

### CMake build fails
Install NDK: `sdkmanager "ndk;26.1.10909125"`

### Flutter not found
Install Flutter: https://docs.flutter.dev/get-started/install

## Post-Build

After building, transfer the APK to your Android device and install. The app works 100% offline - no internet required!