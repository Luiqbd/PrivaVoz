/// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'PrivaVoz';
  static const String appVersion = '1.0.0';
  
  // Trial Configuration
  static const int trialDays = 7;
  static const DateTime? trialEndDate = null; // Set on first launch
  
  // Subscription Prices (in BRL)
  static const double monthlyPrice = 19.90;
  static const double yearlyPrice = 149.90;
  
  // Recording Settings
  static const int autoSaveIntervalSeconds = 30;
  static const String defaultAudioFormat = 'm4a';
  static const int sampleRate = 44100;
  static const int bitRate = 128000;
  
  // AI Model Settings
  static const String whisperModel = 'tiny'; // tiny, base, small, medium
  static const int whisperThreads = 4;
  static const String gemmaModel = 'gemma-2b-it-q4_k_m';
  
  // Security
  static const String encryptionKeyName = 'privavoz_aes_key';
  static const String encryptionIVName = 'privavoz_aes_iv';
  
  // Database
  static const String databaseName = 'privavoz.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String keyTrialStartDate = 'trial_start_date';
  static const String keyTrialActivated = 'trial_activated';
  static const String keySubscriptionActive = 'subscription_active';
  static const String keySubscriptionType = 'subscription_type';
  static const String keyFirstLaunch = 'first_launch';
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double padding = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

/// App Strings
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'PrivaVoz';
  static const String appTagline = 'Gravador de Voz com IA';
  static const String statusBlindado = 'Status: Blindado';
  
  // Navigation
  static const String navRecord = 'Gravar';
  static const String navLibrary = 'Biblioteca';
  static const String navSettings = 'Configurações';
  
  // Recording
  static const String startRecording = 'Iniciar Gravação';
  static const String stopRecording = 'Parar Gravação';
  static const String pauseRecording = 'Pausar Gravação';
  static const String resumeRecording = 'Continuar';
  static const String recordingInProgress = 'Gravando...';
  static const String savingRecording = 'Salvando...';
  
  // Transcription
  static const String transcribe = 'Transcrever';
  static const String transcribing = 'Transcrevendo...';
  static const String transcriptionComplete = 'Transcrição Concluída';
  static const String transcriptionFailed = 'Falha na Transcrição';
  
  // Speakers
  static const String speaker = 'Locutor';
  static const String speaker1 = 'Locutor 1';
  static const String speaker2 = 'Locutor 2';
  static const String speaker3 = 'Locutor 3';
  static const String unknownSpeaker = 'Desconhecido';
  
  // AI Features
  static const String summarize = 'Resumir';
  static const String summarizing = 'Gerando Resumo...';
  static const String extractTasks = 'Extrair Tarefas';
  
  // Security
  static const String biometricPrompt = 'Autentique para acessar';
  static const String biometricTitle = 'PrivaVoz';
  static const String biometricSubtitle = 'Use a biometria para acessar';
  static const String authRequired = 'Autenticação Necessária';
  static const String authFailed = 'Autenticação Falhou';
  static const String tryAgain = 'Tentar Novamente';
  
  // Vault
  static const String vault = 'Cofre';
  static const String vaultLocked = 'Cofre Bloqueado';
  static const String vaultUnlocked = 'Cofre Desbloqueado';
  static const String moveToVault = 'Mover para o Cofre';
  static const String moveFromVault = 'Remover do Cofre';
  
  // Subscription
  static const String upgrade = 'Atualizar';
  static const String premium = 'Premium';
  static const String freeTrial = 'Teste Grátis';
  static const String monthly = 'Mensal';
  static const String yearly = 'Anual';
  static const String bestValue = 'Melhor Valor';
  static const String save50 = '50% OFF';
  static const String unlockAll = 'Desbloquear Todos os Recursos';
  static const String trialExpired = 'Teste Expirado';
  static const String subscribeNow = 'Assine Agora';
  
  // Trial
  static const String trialActive = 'Trial Ativo';
  static const String daysRemaining = 'dias restantes';
  static const String trialDescription = '7 dias de acesso total';
  
  // Errors
  static const String errorGeneric = 'Algo deu errado';
  static const String errorNoMicrophone = 'Microfone não disponível';
  static const String errorNoStorage = 'Armazenamento não disponível';
  static const String errorRecording = 'Falha na gravação';
  static const String errorTranscription = 'Falha na transcrição';
  static const String errorSubscription = 'Falha na assinatura';
  
  // Permissions
  static const String permissionMicrophone = 'Permissão de microfone necessária';
  static const String permissionStorage = 'Permissão de armazenamento necessária';
  static const String permissionBiometric = 'Permissão biométrica necessária';
  static const String grantPermission = 'Conceder Permissão';
  
  // Actions
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String share = 'Compartilhar';
  static const String rename = 'Renomear';
  static const String confirm = 'Confirmar';
  
  // Confirmations
  static const String confirmDelete = 'Tem certeza que deseja excluir?';
  static const String confirmDeleteRecording = 'Esta ação não pode ser desfeita.';
  
  // Empty States
  static const String noRecordings = 'Nenhuma gravação';
  static const String startRecordingHint = 'Toque no botão para começar';
  static const String noTranscription = 'Sem transcrição';
  static const String tapToTranscribe = 'Toque para transcrever';
}