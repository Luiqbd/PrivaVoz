import 'package:flutter/services.dart';

/// Method Channel bridge to native Whisper and Llama libraries
/// This provides the interface between Flutter and Android native code
class NativeAIChannel {
  static const _whisperChannel = MethodChannel('com.privavoz.app/whisper');
  static const _llamaChannel = MethodChannel('com.privavoz.app/llama');

  /// Initialize Whisper with model path
  static Future<bool> initWhisper(String modelPath) async {
    try {
      final result = await _whisperChannel.invokeMethod('init', {'modelPath': modelPath});
      print('[NativeAI] Whisper initialized: $result');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      print('[NativeAI] Whisper init error: ${e.message}');
      return false;
    }
  }

  /// Transcribe audio file
  static Future<String> transcribeAudio(String audioPath) async {
    try {
      final result = await _whisperChannel.invokeMethod('transcribe', {'audioPath': audioPath});
      return result as String? ?? '';
    } on PlatformException catch (e) {
      print('[NativeAI] Transcribe error: ${e.message}');
      return '';
    }
  }

  /// Initialize Llama with model path
  static Future<bool> initLlama(String modelPath) async {
    try {
      final result = await _llamaChannel.invokeMethod('init', {'modelPath': modelPath});
      print('[NativeAI] Llama initialized: $result');
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      print('[NativeAI] Llama init error: ${e.message}');
      return false;
    }
  }

  /// Generate text with Llama
  static Future<String> generateText(String prompt, {int maxTokens = 256}) async {
    try {
      final result = await _llamaChannel.invokeMethod('generate', {
        'prompt': prompt,
        'maxTokens': maxTokens,
      });
      return result as String? ?? '';
    } on PlatformException catch (e) {
      print('[NativeAI] Generate error: ${e.message}');
      return '';
    }
  }

  /// Chat with Llama
  static Future<String> chat(String systemPrompt, String userMessage) async {
    try {
      final result = await _llamaChannel.invokeMethod('chat', {
        'systemPrompt': systemPrompt,
        'userMessage': userMessage,
      });
      return result as String? ?? '';
    } on PlatformException catch (e) {
      print('[NativeAI] Chat error: ${e.message}');
      return '';
    }
  }

  /// Free Whisper resources
  static Future<void> freeWhisper() async {
    try {
      await _whisperChannel.invokeMethod('free');
    } catch (e) {
      print('[NativeAI] Whisper free error: $e');
    }
  }

  /// Free Llama resources
  static Future<void> freeLlama() async {
    try {
      await _llamaChannel.invokeMethod('free');
    } catch (e) {
      print('[NativeAI] Llama free error: $e');
    }
  }

  /// Get native library versions
  static Future<Map<String, String>> getVersions() async {
    try {
      final whisperVersion = await _whisperChannel.invokeMethod('getVersion');
      final llamaVersion = await _llamaChannel.invokeMethod('getVersion');
      return {
        'whisper': whisperVersion as String? ?? 'unknown',
        'llama': llamaVersion as String? ?? 'unknown',
      };
    } catch (e) {
      return {'whisper': 'error', 'llama': 'error'};
    }
  }
}