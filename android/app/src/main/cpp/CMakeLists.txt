# PrivaVoz Native Build (CMake/NDK)

## ⚠️ Experimental - Requires NDK

This CMakeLists.txt requires:
- Android NDK 26.1.10909125
- whisper.cpp and llama.cpp sources (download separately)

## Simplified Build (No Native libs)

For build WITHOUT native FFI (works without NDK):
```bash
# Just builds with mock AI - no whisper.so or llama.so
flutter build apk --release
```

## Full Build with Native FFI

The GitHub Actions workflow handles this automatically:
- Downloads whisper.cpp and llama.cpp
- Compiles libwhisper.so and libllama.so with NDK
- Bundles in APK

See: `.github/workflows/build.yml`