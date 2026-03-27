import 'dart:async';
import 'dart:isolate';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/recording.dart';

/// AI Service - Handles AI processing (Transcription, Diarization, Summary)
/// Note: This is a mock implementation for demonstration
/// Real implementation will use FFI with whisper.cpp and llama.cpp
class AIService {
  static final Uuid _uuid = const Uuid();
  
  /// Transcribe audio file (mock implementation)
  /// In production, this would use whisper.cpp FFI
  static Future<Transcription> transcribe(String audioPath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 3));
    
    // Mock transcription result
    // In production, this would come from whisper.cpp with word-level timestamps
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
        endTime: 3.5,
        text: 'vamos começar a reunião',
      ),
    ];
    
    return Transcription(
      id: _uuid.v4(),
      recordingId: '', // Will be set by caller
      text: 'Olá tudo bem? Sim perfeito então vamos começar a reunião',
      words: mockWords,
      speakerSegments: mockSpeakerSegments,
      createdAt: DateTime.now(),
      confidence: 0.95,
    );
  }
  
  /// Process transcription in isolate for better performance
  static Future<Transcription> transcribeInIsolate(String audioPath) async {
    return await Isolate.run(() => transcribe(audioPath));
  }
  
  /// Generate summary using Gemma (mock implementation)
  /// In production, this would use llama.cpp with Gemma 2b
  static Future<Summary> summarize(Transcription transcription) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock summary result
    return Summary(
      id: _uuid.v4(),
      recordingId: transcription.recordingId,
      summaryText: 'Esta gravação contém uma reunião inicial onde os participantes cumprimentam-se e preparam-se para iniciar a discussão principal.',
      actionItems: [
        'Agendar próxima reunião',
        'Preparar materiais para apresentação',
        'Enviar convite para participantes',
      ],
      keywords: ['reunião', 'início', 'agenda', 'presentes'],
      createdAt: DateTime.now(),
    );
  }
  
  /// Extract action items from transcription
  static Future<List<String>> extractActionItems(Transcription transcription) async {
    // Simulate processing
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock action items
    return [
      'Revisar documento',
      'Enviar relatório',
      'Agendar follow-up',
    ];
  }
  
  /// Perform speaker diarization (identify different speakers)
  static Future<List<SpeakerSegment>> diarize(String audioPath) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock diarization result
    return [
      SpeakerSegment(
        speakerId: 1,
        speakerLabel: 'Locutor 1',
        startTime: 0.0,
        endTime: 5.0,
        text: 'Olá pessoal, sejam bem vindos à reunião...',
      ),
      SpeakerSegment(
        speakerId: 2,
        speakerLabel: 'Locutor 2',
        startTime: 5.0,
        endTime: 10.0,
        text: 'Obrigado! Estou feliz por estar aqui...',
      ),
      SpeakerSegment(
        speakerId: 1,
        speakerLabel: 'Locutor 1',
        startTime: 10.0,
        endTime: 15.0,
        text: 'Vamos começar verificando a agenda do dia...',
      ),
    ];
  }
  
  /// Check if AI models are loaded
  static bool get isModelLoaded => true;
  
  /// Get current model info
  static Map<String, dynamic> get modelInfo => {
    'whisper': 'tiny (4-bit quantized)',
    'gemma': '2b-it Q4_K_M',
    'status': 'ready',
  };
}

/// Progress callback for long-running operations
typedef AIProgressCallback = void Function(double progress, String message);

/// AI Processing isolate entry point
class AIProcessingIsolate {
  static void processTranscription(SendPort sendPort) {
    // This would handle actual FFI calls in production
  }
}