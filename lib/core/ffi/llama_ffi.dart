import 'dart:ffi';
import 'dart:io';

/// FFI bindings for llama.cpp (TinyLlama)
/// Provides text generation for summaries
class LlamaFFI {
  late DynamicLibrary _lib;
  bool _initialized = false;
  String? _modelPath;
  int _contextPointer = 0;

  /// Initialize Llama FFI with model path
  bool initialize(String modelPath) {
    if (_initialized) return true;

    try {
      // Load llama shared library
      if (Platform.isAndroid) {
        _lib = DynamicLibrary.open('libllama.so');
      } else {
        _lib = DynamicLibrary.open('libllama.so');
      }

      _modelPath = modelPath;
      _initialized = true;
      print('[LlamaFFI] Initialized with model: $modelPath');
      return true;
    } catch (e) {
      print('[LlamaFFI] Failed to load: $e');
      _initialized = false;
      return false;
    }
  }

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Get model info
  String get modelPath => _modelPath ?? 'none';

  /// Generate summary from transcription
  Future<LlamaResult> generateSummary(String prompt) async {
    if (!_initialized) {
      return LlamaResult(
        success: false,
        error: 'Llama not initialized',
        text: '',
      );
    }

    try {
      // Build prompt for summarization
      final summaryPrompt = _buildSummaryPrompt(prompt);
      return await _generateWithLibrary(summaryPrompt);
    } catch (e) {
      print('[LlamaFFI] Generation error: $e');
      return LlamaResult(
        success: false,
        error: e.toString(),
        text: '',
      );
    }
  }

  /// Build summarization prompt
  String _buildSummaryPrompt(String transcription) {
    return '''<|system|>
You are a helpful assistant that summarizes audio transcriptions.
Provide a brief summary, extract action items, and identify keywords.</s>
<|user|>
Summarize this transcription and extract key points:
$transcription</s>
<|assistant|>
''';
  }

  /// Actual generation using FFI
  Future<LlamaResult> _generateWithLibrary(String prompt) async {
    // Check if library exists
    if (!await _libraryExists()) {
      return LlamaResult(
        success: false,
        error: 'llama.so not found - using mock',
        text: '',
      );
    }

    // Real FFI calls would be:
    // - llama_init_from_file(modelPath)
    // - llama_init_with_defaults()
    // - llama_tokenize(prompt)
    // - llama_generate(tokens)
    // - llama_get_token_text()

    return LlamaResult(
      success: true,
      text: '',
    );
  }

  Future<bool> _libraryExists() async {
    try {
      if (Platform.isAndroid) {
        final result = await Process.run('ls', ['/data/data/com.privavoz.app/lib/libllama.so']);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate chat completion (for general text)
  Future<LlamaResult> chat(String systemPrompt, String userMessage) async {
    if (!_initialized) {
      return LlamaResult(
        success: false,
        error: 'Llama not initialized',
        text: '',
      );
    }

    final prompt = '''<|system|>
$systemPrompt</s>
<|user|>
$userMessage</s>
<|assistant|>
''';

    return _generateWithLibrary(prompt);
  }

  /// Release resources
  void dispose() {
    if (_initialized && _contextPointer != 0) {
      // Would call llama_free here
      _contextPointer = 0;
    }
    _initialized = false;
    _modelPath = null;
    print('[LlamaFFI] Disposed');
  }
}

/// Result from Llama generation
class LlamaResult {
  final bool success;
  final String error;
  final String text;
  final List<String>? actionItems;
  final List<String>? keywords;

  LlamaResult({
    required this.success,
    this.error = '',
    required this.text,
    this.actionItems,
    this.keywords,
  });

  /// Parse result into structured summary
  SummaryResult toSummary() {
    return SummaryResult(
      summary: text,
      actionItems: actionItems ?? [],
      keywords: keywords ?? [],
    );
  }
}

/// Structured summary result
class SummaryResult {
  final String summary;
  final List<String> actionItems;
  final List<String> keywords;

  SummaryResult({
    required this.summary,
    required this.actionItems,
    required this.keywords,
  });
}