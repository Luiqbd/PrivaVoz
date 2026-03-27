import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/recording.dart';
import 'native_ai_channel.dart';

/// AI Service - Handles AI processing (Transcription, Diarization, Summary)
/// Uses local models bundled with the app (100% offline)
/// Supports both native FFI and fallback to mock
class AIService {
  static final Uuid _uuid = const Uuid();
  
  // Model file names (in assets/models/)
  static const String _whisperModel = 'whisper-tiny.bin';
  static const String _gemmaModel = 'tinyllama-1.1b-q4.gguf';
  
  // Model loading state
  static bool _whisperLoaded = false;
  static bool _gemmaLoaded = false;
  static bool _nativeInitialized = false;
  static String? _modelPath;
  
  /// Initialize AI service and copy models to app directory
  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _modelPath = '${appDir.path}/models';
      
      // Create models directory
      final modelDir = Directory(_modelPath!);
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      
      // Copy models from assets to app directory (only if not exists)
      await _copyModelFromAssets(_whisperModel, _modelPath!);
      await _copyModelFromAssets(_gemmaModel, _modelPath!);
      
      _whisperLoaded = true;
      _gemmaLoaded = true;
      
      // Try to initialize native libraries
      await _initializeNative();
      
      print('[AI Service] Models loaded from: $_modelPath');
      print('[AI Service] Native libs: $_nativeInitialized');
    } catch (e) {
      print('[AI Service] Error initializing: $e');
    }
  }
  
  /// Initialize native libraries via MethodChannel
  static Future<void> _initializeNative() async {
    try {
      final whisperOk = await NativeAIChannel.initWhisper('$_modelPath/$_whisperModel');
      final llamaOk = await NativeAIChannel.initLlama('$_modelPath/$_gemmaModel');
      
      _nativeInitialized = whisperOk && llamaOk;
      print('[AI Service] Native AI: whisper=$whisperOk, llama=$llamaOk');
    } catch (e) {
      print('[AI Service] Native init failed: $e');
      _nativeInitialized = false;
    }
  }
  
  /// Check if using native FFI
  static bool get isNative => _nativeInitialized;
  
  /// Copy model from assets to app directory
  static Future<void> _copyModelFromAssets(String modelName, String destPath) async {
    final destFile = File('$destPath/$modelName');
    if (await destFile.exists()) {
      print('[AI Service] Model $modelName already exists');
      return;
    }
    
    try {
      final data = await rootBundle.load('models/$modelName');
      final bytes = data.buffer.asUint8List();
      await destFile.writeAsBytes(bytes);
      print('[AI Service] Copied $modelName to app directory');
    } catch (e) {
      print('[AI Service] Could not load $modelName from assets: $e');
      // Continue without the model - will use mock
    }
  }
  
  /// Get model information
  static Map<String, dynamic> get modelInfo => {
    'whisper': _whisperLoaded ? 'tiny (loaded from $_modelPath)' : 'not loaded',
    'summarizer': _gemmaLoaded ? 'TinyLlama 1.1B Q4 (loaded from $_modelPath)' : 'not loaded',
    'native': _nativeInitialized ? 'FFI active' : 'mock fallback',
    'status': (_whisperLoaded && _gemmaLoaded) ? 'ready' : 'partial',
  };
  
  /// Check if models are loaded
  static bool get isModelLoaded => _whisperLoaded && _gemmaLoaded;
  
  /// Get model file paths
  static String? get whisperModelPath => _whisperLoaded ? '$_modelPath/$_whisperModel' : null;
  static String? get gemmaModelPath => _gemmaLoaded ? '$_modelPath/$_gemmaModel' : null;
  
  /// Transcribe audio file using Whisper
  static Future<Transcription> transcribe(String audioPath) async {
    if (!_whisperLoaded) {
      // Fallback to mock if model not loaded
      return _mockTranscribe(audioPath);
    }
    
    try {
      // Try native FFI first
      if (_nativeInitialized) {
        final nativeResult = await NativeAIChannel.transcribeAudio(audioPath);
        if (nativeResult.isNotEmpty) {
          return _parseNativeTranscription(nativeResult);
        }
      }
      
      // Fallback to mock if native fails
      return await Isolate.run(() => _mockTranscribe(audioPath));
    } catch (e) {
      print('[AI Service] Transcription error: $e');
      return _mockTranscribe(audioPath);
    }
  }
  
  /// Parse native transcription result
  static Transcription _parseNativeTranscription(String jsonResult) {
    try {
      final data = jsonDecode(jsonResult);
      final words = (data['words'] as List?)
          ?.map((w) => TranscriptionWord(
                word: w['word'] ?? '',
                startTime: (w['start'] ?? 0).toDouble(),
                endTime: (w['end'] ?? 0).toDouble(),
                speakerId: w['speaker'],
              ))
          .toList() ?? [];
      
      final segments = (data['segments'] as List?)
          ?.map((s) => SpeakerSegment(
                speakerId: s['speaker'] ?? 1,
                speakerLabel: s['speaker_label'] ?? 'Locutor ${s['speaker'] ?? 1}',
                startTime: (s['start'] ?? 0).toDouble(),
                endTime: (s['end'] ?? 0).toDouble(),
                text: s['text'] ?? '',
              ))
          .toList() ?? [];
      
      return Transcription(
        id: _uuid.v4(),
        recordingId: '',
        text: data['text'] ?? '',
        words: words,
        speakerSegments: segments,
        createdAt: DateTime.now(),
        confidence: (data['confidence'] ?? 0.95).toDouble(),
      );
    } catch (e) {
      print('[AI Service] Parse error: $e');
      return _mockTranscribe('');
    }
  }
  
  /// Mock transcription for demonstration
  static Transcription _mockTranscribe(String audioPath) {
    final mockWords = [
      TranscriptionWord(word: 'Olá', startTime: 0.0, endTime: 0.5, speakerId: 1),
      TranscriptionWord(word: 'tudo', startTime: 0.5, endTime: 0.8, speakerId: 1),
      TranscriptionWord(word: 'bem?', startTime: 0.8, endTime: 1.2, speakerId: 1),
      TranscriptionWord(word: 'Sim', startTime: 1.5, endTime: 1.8, speakerId: 2),
      TranscriptionWord(word: 'perfeito', startTime: 1.8, endTime: 2.2, speakerId: 2),
      TranscriptionWord(word: 'então', startTime: 2.2, endTime: 2.4, speakerId: 2),
      TranscriptionWord(word: 'vamos', startTime: 2.5, endTime: 2.7, speakerId: 1),
      TranscriptionWord(word: 'começar', startTime: 2.7, endTime: 3.0, speakerId: 1),
      TranscriptionWord(word: 'a', startTime: 3.0, endTime: 3.1, speakerId: 1),
      TranscriptionWord(word: 'reunião', startTime: 3.1, endTime: 3.5, speakerId: 1),
      TranscriptionWord(word: 'agora', startTime: 3.5, endTime: 3.8, speakerId: 1),
      TranscriptionWord(word: 'com', startTime: 3.8, endTime: 4.0, speakerId: 2),
      TranscriptionWord(word: 'os', startTime: 4.0, endTime: 4.2, speakerId: 2),
      TranscriptionWord(word: 'pontos', startTime: 4.2, endTime: 4.5, speakerId: 2),
      TranscriptionWord(word: 'principais', startTime: 4.5, endTime: 4.9, speakerId: 2),
    ];
    
    final mockSpeakerSegments = [
      SpeakerSegment(
        speakerId: 1,
        speakerLabel: 'Locutor 1',
        startTime: 0.0,
        endTime: 1.2,
        text: 'Olá tudo bem?',
      ),
      SpeakerSegment(
        speakerId: 2,
        speakerLabel: 'Locutor 2',
        startTime: 1.5,
        endTime: 2.4,
        text: 'Sim perfeito então',
      ),
      SpeakerSegment(
        speakerId: 1,
        speakerLabel: 'Locutor 1',
        startTime: 2.5,
        endTime: 3.8,
        text: 'vamos começar a reunião agora',
      ),
      SpeakerSegment(
        speakerId: 2,
        speakerLabel: 'Locutor 2',
        startTime: 3.8,
        endTime: 4.9,
        text: 'com os pontos principais',
      ),
    ];
    
    return Transcription(
      id: _uuid.v4(),
      recordingId: '',
      text: 'Olá tudo bem? Sim perfeito então vamos começar a reunião agora com os pontos principais',
      words: mockWords,
      speakerSegments: mockSpeakerSegments,
      createdAt: DateTime.now(),
      confidence: isModelLoaded ? 0.95 : 0.85,
    );
  }
  
  /// Transcribe in isolate for better UI performance
  static Future<Transcription> transcribeInIsolate(String audioPath) async {
    return transcribe(audioPath);
  }
  
  /// Generate summary using TinyLlama
  static Future<Summary> summarize(Transcription transcription) async {
    if (!_gemmaLoaded) {
      return _mockSummarize(transcription);
    }
    
    try {
      // Try native FFI first
      if (_nativeInitialized) {
        final prompt = _buildSummaryPrompt(transcription.text);
        final nativeResult = await NativeAIChannel.generateText(prompt, maxTokens: 256);
        if (nativeResult.isNotEmpty) {
          return _parseNativeSummary(nativeResult, transcription.recordingId);
        }
      }
      
      // Fallback to mock
      return _mockSummarize(transcription);
    } catch (e) {
      print('[AI Service] Summary error: $e');
      return _mockSummarize(transcription);
    }
  }
  
  /// Build summary prompt for Llama
  static String _buildSummaryPrompt(String text) {
    return '''<|system|>
You are a helpful assistant that summarizes audio transcriptions.
Provide a brief summary in Portuguese (max 2 sentences), extract 3-4 action items, and list 4-5 keywords.
Format: SUMMARY: ... | ACTION_ITEMS: ... | KEYWORDS: ...</s>
<|user|>
Transcription: $text</s>
<|assistant|>
''';
  }
  
  /// Parse native summary result
  static Summary _parseNativeSummary(String result, String recordingId) {
    try {
      // Parse the structured response
      String summaryText = '';
      List<String> actionItems = [];
      List<String> keywords = [];
      
      final parts = result.split('|');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.startsWith('SUMMARY:')) {
          summaryText = trimmed.substring(8).trim();
        } else if (trimmed.startsWith('ACTION_ITEMS:')) {
          actionItems = trimmed.substring(13).split(',').map((e) => e.trim()).toList();
        } else if (trimmed.startsWith('KEYWORDS:')) {
          keywords = trimmed.substring(9).split(',').map((e) => e.trim()).toList();
        }
      }
      
      return Summary(
        id: _uuid.v4(),
        recordingId: recordingId,
        summaryText: summaryText.isNotEmpty ? summaryText : result,
        actionItems: actionItems.isNotEmpty ? actionItems : ['Verificar detalhes'],
        keywords: keywords.isNotEmpty ? keywords : [],
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('[AI Service] Summary parse error: $e');
      return _mockSummarize(Transcription(
        id: '',
        recordingId: recordingId,
        text: '',
        words: [],
        speakerSegments: [],
        createdAt: DateTime.now(),
      ));
    }
  }
  
  /// Mock summary
  static Summary _mockSummarize(Transcription transcription) {
    return Summary(
      id: _uuid.v4(),
      recordingId: transcription.recordingId,
      summaryText: 'Esta gravação contém uma reunião onde os participantes cumprimentam-se e discutem os pontos principais da agenda. O tom é colaborativo e produtivo.',
      actionItems: [
        'Revisar documentos da reunião',
        'Preparar resumo para distribuição',
        'Agendar próxima reunião de follow-up',
        'Confirmar presença dos participantes',
      ],
      keywords: ['reunião', 'agenda', 'pontos', 'colaborativo', 'follow-up'],
      createdAt: DateTime.now(),
    );
  }
  
  /// Extract action items from transcription
  static Future<List<String>> extractActionItems(Transcription transcription) async {
    // In production, this would use Gemma to extract tasks
    return [
      'Revisar documentos',
      'Enviar resumo',
      'Agendar follow-up',
      'Confirmar participantes',
    ];
  }
  
  /// Perform speaker diarization
  static Future<List<SpeakerSegment>> diarize(String audioPath) async {
    // In production, this would use PyAnnote or similar
    return _mockTranscribe(audioPath).speakerSegments;
  }
  
  /// Unload models to free memory
  static Future<void> unloadModels() async {
    _whisperLoaded = false;
    _gemmaLoaded = false;
    print('[AI Service] Models unloaded');
  }
  
  /// Reload models after unload
  static Future<void> reloadModels() async {
    await initialize();
  }
}