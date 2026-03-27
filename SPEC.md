# PrivaVoz - Especificação Técnica Completa

## 1. Visão Geral do Projeto

**Nome:** PrivaVoz (PrivaVoice em Espanhol/Português)
**Tipo:** Aplicativo Android - Gravador de Voz com IA
**Objetivo:** Criar um gravador de voz offline com recursos avançados de IA, incluindo transcrição com timestamps, diarização de falantes, resumos automáticos, e interface premium com glassmorphism.

---

## 2. Especificação de Requisitos

### 2.1 Motores de IA (FFI e Processamento Local)

#### Transcrição & Karaokê
- **Engine:** Whisper.cpp via Dart FFI
- **Configuração:** Extrair Word-Level Timestamps (timestamps por palavra)
- **Player Karaokê:** 
  - Destaque visual progressivo das palavras durante reprodução
  - Função seekTo imediato ao tocar no texto transcrito
- **Modelo:** Whisper tiny/base quantizado 4-bit para dispositivos médios

#### Diarização de Voz
- **Funcionalidade:** Identificação de múltiplos falantes
- **Naming:** "Locutor 1", "Locutor 2", etc.
- **Implementação:** pyannote.audio ou similar via FFI para segmentação de falantes

#### Organização (Gemma 2b)
- **Engine:** Gemma 2b via llama.cpp
- **Funcionalidades:**
  - Resumos automáticos de transcrições
  - Extração de tarefas/action items
  - Categorização de gravações
- **Modelo:** Gemma 2b Q4_K_M quantizado

### 2.2 Gestão de Memória (Otimização para Celulares Médios)

#### Quantização 4-bit
- Modelos Whisper e Gemma em quantization Q4_K_M
- Redução de ~80% no uso de RAM

#### Dynamic Loading
- Carregar modelos na memória apenas durante processamento
- Liberar memória imediatamente após uso
- Gestão automática de memória com isolate_cleanup

#### Isolates
- Processamento de IA em threads separadas (Dart Isolates)
- Interface 100% fluida durante processamento
- Não bloquear UI durante transcrição/resumo

### 2.3 Segurança e Robustez

#### Zero Internet
- Remover completamente permissão INTERNET do AndroidManifest
- Todas as operações offline
- Sem chamadas de rede

#### Criptografia
- **AES-256** para:
  - Arquivos de áudio gravados
  - Transcrições e textos salvos
- Implementação via encrypt package ou cryptography_native

#### Cofre Biométrico
- **local_auth** para:
  - Pastas privadas (pasta segura)
  - Acesso ao aplicativo
- Autenticação biométrica (impressão digital, Face ID)

#### Estabilidade
- **Foreground Service** para gravação contínua
- **Auto-Save** a cada 30 segundos
- Proteção contra desligamentos inesperados
- Notificação persistente durante gravação

### 2.4 Modelo de Negócio (Paywall Offline)

#### Trial Inteligente
- 7 dias de acesso total liberado na instalação
- Após período Trial:
  - Bloqueio de novas gravações
  - Bloqueio de recursos de IA (transcrição, resumo)
  - Acesso apenas a gravações existentes
-tracking de período via SharedPreferences com timestamp

#### Assinaturas
- **Plugin:** in_app_purchase ou flutter_iap
- **Validação:** Local de recibo (sem servidor)
- **Valores:**
  - Mensal: R$ 19,90 (50% OFF)
  - Anual: R$ 149,90 (40% OFF - melhor valor)
- Promoções destacadas na UI

### 2.5 Interface Premium (Glassmorphism)

#### Tema Dark Mode
- Fundo preto profundo (#0A0A0A)
- Detalhes em neon:
  - Cyan (#00F5FF)
  - Magenta (#FF00FF)
  - Verde Neon (#39FF14)
- Gradientes e transparências

#### Elementos UI
- Glassmorphism: blur, transparências, bordas translúcidas
- Indicador fixo de "Status: Blindado" no topo
- Ondas sonoras orgânicas em tempo real (waveform)
- Feedback tátil (Haptic Feedback) em interações

#### Componentes
- Cards com vidro fosco
- Botões com glow effect
- Animações fluidas
- Ícones neon estilizados

---

## 3. Arquitetura Técnica

### 3.1 Stack Tecnológico

- **Framework:** Flutter 3.x
- **Linguagem:** Dart 3.x
- **Plataforma:** Android (API 21+)
- **State Management:** flutter_bloc (BLoC pattern)
- **Arquitetura:** Clean Architecture (Presentation/Domain/Data)

### 3.2 Estrutura de Diretórios

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── extensions/
├── data/
│   ├── repositories/
│   ├── datasources/
│   └── models/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/
```

### 3.3 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Audio Recording
  record: ^5.0.4
  just_audio: ^0.9.36
  
  # IA & FFI
  ffi: ^2.1.0
  
  # Security
  local_auth: ^2.1.8
  encrypt: ^5.0.3
  flutter_secure_storage: ^9.0.0
  
  # Storage
  path_provider: ^2.1.1
  sqflite: ^2.3.0
  
  # UI Components
  flutter_svg: ^2.0.9
  lottie: ^3.0.0
  shimmer: ^3.0.0
  
  # Utils
  permission_handler: ^11.1.0
  uuid: ^4.2.1
  intl: ^0.18.1
  share_plus: ^7.2.1
  
  # Monetization
  in_app_purchase: ^5.0.1
  
  # Services
  flutter_local_notifications: ^16.1.0
```

### 3.4 Configuração Android

#### AndroidManifest.xml - Permissões e Configurações
```xml
<!-- Sem INTERNET - 100% Offline -->
<!-- <uses-permission android:name="android.permission.INTERNET"/> -->

<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

---

## 4. Funcionalidades Detalhadas

### 4.1 Gravação de Áudio
- Iniciar/Pausar/Parar gravação
- Visualização de waveform em tempo real
- Timer de duração
- Gravação em background (Foreground Service)
- Auto-save a cada 30 segundos
- Formato: M4A/AAC de alta qualidade

### 4.2 Biblioteca de Gravações
- Lista de todas as gravações
-ordenação por data
- Busca por nome
- Exclusão com confirmação
- Reprodução inline

### 4.3 Player com Karaokê
- Reprodução de áudio
- Transcrição exibida com timestamps
- Destaque visual da palavra atual (karaokê)
- Seek ao tocar na palavra
- Controles: play/pause, seek, velocidade

### 4.4 IA - Transcrição
- Botão para iniciar transcrição
- Processamento em isolate
- Word-level timestamps
- Progress indicator durante processamento

### 4.5 IA - Diarização
- Identificação de falantes
- Marcação visual por locutor
- Color coding para cada locutor

### 4.6 IA - Resumo (Gemma)
- Geração de resumo automático
- Extração de action items
- Categorização sugerida

### 4.7 Pasta Segura (Cofre)
- Acesso apenas com biometria
- Mover gravações para pasta segura
- Lista separado de gravações protegidas

### 4.8 Configurações
- Qualidade de gravação
- Tamanho de modelo IA
- Configurações de segurança
- Gerenciamento de Trial/Assinatura

---

## 5. UI/UX Specification

### 5.1 Cores

```dart
// Cores Principais
static const Color primaryDark = Color(0xFF0A0A0A);
static const Color surfaceDark = Color(0xFF1A1A1A);
static const Color cardDark = Color(0xFF252525);

// Neon Colors
static const Color neonCyan = Color(0xFF00F5FF);
static const Color neonMagenta = Color(0xFFFF00FF);
static const Color neonGreen = Color(0xFF39FF14);
static const Color neonOrange = Color(0xFFFF6B35);

// Text Colors
static const Color textPrimary = Color(0xFFFFFFFF);
static const Color textSecondary = Color(0xFFB0B0B0);
static const Color textMuted = Color(0xFF707070);
```

### 5.2 Componentes

#### GlassCard
- Fundo com blur
- Borda translúcida
- Sombra suave colorida

#### NeonButton
- Glow effect
- Animação de pulsação
- Feedback haptic

#### StatusBadge
- "Status: Blindado" fixo
- Ícone de bloqueio
- Cor verde de segurança

#### WaveformVisualizer
- Ondas orgânicas animadas
- Cor gradient cyan
- Resposta em tempo real

### 5.3 Telas

1. **Home/Gravação** - Tela principal com gravador
2. **Biblioteca** - Lista de gravações
3. **Player** - Reprodução com karaokê
4. **Cofre** - Pasta segura
5. **Configurações** - Ajustes do app
6. **Assinatura** - Paywall e upgrade

---

## 6. Implementação FFI

### 6.1 Whisper.cpp Integration

```dart
// Estrutura básica para FFI
class WhisperFFI {
  static DynamicLibrary? _lib;
  
  // Funções nativas necessárias:
  // - whisper_init_from_file
  // - whisper_full
  // - whisper_free
  
  // 处理Word-level timestamps
}
```

### 6.2 Gemma.cpp Integration

```dart
// Estrutura básica para FFI
class GemmaFFI {
  static DynamicLibrary? _lib;
  
  // Funções nativas:
  // - gemma_load_model
  // - gemma_generate
  // - gemma_free
}
```

---

## 7. Mock para Desenvolvimento

Como não temos os binários FFI nativos, implementaremos:
- Interface abstrata para transcrição
- Simulação de transcrição com delays
- Dados mock para demonstration
- Preparação completa para FFI real

---

## 8. Critérios de Qualidade

1. ✅ Interface 100% fluida (60fps)
2. ✅ Sem uso de internet
3. ✅ Arquivos criptografados
4. ✅ Biometria funcional
5. ✅ Trial de 7 dias
6. ✅ Gravação em background
7. ✅ Waveform em tempo real
8. ✅ Player com highlight
9. ✅ Dark mode com neon