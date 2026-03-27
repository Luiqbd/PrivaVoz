# PrivaVoz 🇧🇷🇪🇸

**PrivaVoz** (PrivaVoice) - Gravador de Voz com IA 100% Offline

Um gravador de voz inteligente com recursos avançados de IA que funciona completamente offline, sem necessidade de internet. Desenvolvido com Flutter para Android.

![Platform](https://img.shields.io/badge/Platform-Android-green)
![Language](https://img.shields.io/badge/Language-Dart-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🚀 Funcionalidades

### 🎙️ Gravação
- Gravação de áudio de alta qualidade (M4A/AAC)
- Visualização de ondas sonoras em tempo real
- Auto-save a cada 30 segundos
- Gravação em background (Foreground Service)
- Temporizador de duração

### 🤖 Inteligência Artificial
- **Transcrição**: Whisper.cpp via FFI com timestamps por palavra
- **Karaokê**: Destaque visual progressivo durante reprodução
- **Diarização**: Identificação de múltiplos falantes (Locutor 1, Locutor 2...)
- **Resumos**: Gemma 2b para resumos automáticos e extraction de tarefas
- Processamento em Isolate para interface 100% fluida

### 🔒 Segurança
- **Zero Internet**: Sem permissão de INTERNET - 100% offline
- **Criptografia AES-256**: Todos os áudios e textos criptografados
- **Cofre Biométrico**: Pastas privadas com autenticação (local_auth)
- **Foreground Service**: Gravação contínua mesmo com app fechado

### 💎 Premium
- **Trial Inteligente**: 7 dias de acesso total
- **Assinaturas**: R$ 19,90/mês ou R$ 149,90/ano (40-50% OFF)
- Paywall com validação local de recibo

### 🎨 Interface
- **Glassmorphism**: Design moderno com blur e transparências
- **Dark Mode**: Fundo preto profundo (#0A0A0A) com neon
- **Feedback Tátil**: Haptic feedback em todas interações
- Indicador "Status: Blindado"

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration
├── core/
│   ├── constants/               # App constants
│   ├── theme/                   # Theme (dark/neon)
│   ├── services/                # Core services
│   │   ├── ai_service.dart      # IA processing
│   │   ├── biometric_service.dart
│   │   ├── encryption_service.dart
│   │   ├── recording_service.dart
│   │   └── subscription_service.dart
│   └── utils/
├── data/
│   ├── datasources/             # Database
│   └── repositories/
├── domain/
│   ├── entities/                # Business entities
│   └── repositories/
└── presentation/
    ├── blocs/                   # State management
    ├── pages/                   # UI screens
    └── widgets/                 # Reusable widgets
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: flutter_bloc (BLoC pattern)
- **Architecture**: Clean Architecture
- **Database**: SQLite (sqflite)
- **Security**: encrypt, flutter_secure_storage
- **Audio**: record, just_audio
- **Biometrics**: local_auth
- **AI**: FFI com Whisper.cpp e llama.cpp (mock para demo)

## 📋 Requisitos

- Android API 21+ (Lollipop)
- Sem necessidade de internet
- Permissões: Microfone, Armazenamento, Biometria

## 🔧 Configuração

1. Clone o repositório
2. Execute `flutter pub get`
3. Execute `flutter build apk --debug`

## 📱 Screenshots

| Tela Inicial | Biblioteca | Player | Configurações |
|-------------|------------|--------|---------------|
| 🎙️ | 📁 | ▶️ | ⚙️ |

## 📄 Licença

MIT License - see [LICENSE](LICENSE) for details.

---

Desenvolvido com ❤️ por PrivaVoz Team

**Nota**: Este projeto inclui implementação mock dos recursos de IA (Whisper, Gemma) para demonstração. Para produção, os binários nativos FFI precisam ser compilados e incluídos.