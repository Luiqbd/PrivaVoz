# PrivaVoz - Build Automático

## Como funciona

Este projeto usa **GitHub Actions** para compilar o APK automaticamente com IA nativa!

### Configuração Atual:

1. ✅ **Modelos IA** - Baixados do GitHub Release (712MB)
2. ✅ **whisper.cpp** + **llama.cpp** - Clonados automaticamente
3. ✅ **NDK 26.1.10909125** - Instalado no CI
4. ✅ **libwhisper.so + libllama.so** - Compilados automaticamente

### Trigger do Build:

Vá até: https://github.com/Luiqbd/PrivaVoz/actions

Clique em **"Build PrivaVoz APK"** → **Run workflow**

### Output:

- `app-debug.apk` - Versão debug (~50MB)
- `app-release.apk` - Versão release (~45MB)

Os APKs incluem:
- Modelos IA embarcados
- Bibliotecas nativas (.so)
- **100% offline!**

### Download APK Final:

Após o build, baixe em:
**https://github.com/Luiqbd/PrivaVoz/releases**

---

## Desenvolvimento Local

Se quiser compilar local (sem NDK):

```bash
# Apenas código Dart (IA usa mock)
flutter build apk --release
```

Para completo com NDK, você precisa:
- Android Studio + NDK 26.1.10909125
- Baixar modelos manualmente
- Compilar com CMake