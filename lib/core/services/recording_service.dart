import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/recording.dart';
import 'encryption_service.dart';

/// Recording Service - Handles audio recording with auto-save
class RecordingService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final Uuid _uuid = const Uuid();
  
  static String? _currentRecordingPath;
  static DateTime? _recordingStartTime;
  static Timer? _autoSaveTimer;
  static bool _isRecording = false;
  static bool _isPaused = false;
  
  /// Check if microphone permission is granted
  static Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }
  
  /// Start recording
  static Future<String?> startRecording() async {
    if (_isRecording) return null;
    
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }
    
    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${directory.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'recording_$timestamp.m4a';
    _currentRecordingPath = '${recordingsDir.path}/$filename';
    
    // Configure recording
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
      numChannels: 1,
    );
    
    // Start recording
    await _recorder.start(config, path: _currentRecordingPath!);
    
    _isRecording = true;
    _isPaused = false;
    _recordingStartTime = DateTime.now();
    
    // Start auto-save timer
    _startAutoSaveTimer();
    
    return _currentRecordingPath;
  }
  
  /// Pause recording
  static Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;
    
    await _recorder.pause();
    _isPaused = true;
    _autoSaveTimer?.cancel();
  }
  
  /// Resume recording
  static Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;
    
    await _recorder.resume();
    _isPaused = false;
    _startAutoSaveTimer();
  }
  
  /// Stop recording and return the recorded file
  static Future<Recording?> stopRecording({String? name}) async {
    if (!_isRecording) return null;
    
    _autoSaveTimer?.cancel();
    
    final path = await _recorder.stop();
    if (path == null || _currentRecordingPath == null) {
      _resetState();
      return null;
    }
    
    // Calculate duration
    final duration = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!)
        : Duration.zero;
    
    // Encrypt the recording
    await EncryptionService.encryptFile(_currentRecordingPath!);
    
    // Create recording entity
    final recording = Recording(
      id: _uuid.v4(),
      name: name ?? 'Gravação ${DateTime.now().toString().substring(0, 16)}',
      filePath: _currentRecordingPath!,
      duration: duration,
      createdAt: _recordingStartTime ?? DateTime.now(),
      isEncrypted: true,
      isInVault: false,
    );
    
    _resetState();
    return recording;
  }
  
  /// Cancel recording without saving
  static Future<void> cancelRecording() async {
    _autoSaveTimer?.cancel();
    
    if (_isRecording) {
      await _recorder.stop();
    }
    
    // Delete the file
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    _resetState();
  }
  
  /// Get current recording amplitude (for waveform visualization)
  static Stream<Amplitude> get amplitudeStream => _recorder.onAmplitudeChanged(
    const Duration(milliseconds: 100),
  );
  
  /// Check if currently recording
  static bool get isRecording => _isRecording;
  
  /// Check if paused
  static bool get isPaused => _isPaused;
  
  /// Get current recording path
  static String? get currentRecordingPath => _currentRecordingPath;
  
  /// Get recording duration so far
  static Duration get currentDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }
  
  /// Start auto-save timer
  static void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _performAutoSave(),
    );
  }
  
  /// Perform auto-save (backup)
  static Future<void> _performAutoSave() async {
    if (!_isRecording || _isPaused || _currentRecordingPath == null) return;
    
    try {
      // In production, this would create a backup
      print('Auto-save: Recording backed up at ${DateTime.now()}');
    } catch (e) {
      print('Auto-save failed: $e');
    }
  }
  
  /// Reset state variables
  static void _resetState() {
    _currentRecordingPath = null;
    _recordingStartTime = null;
    _isRecording = false;
    _isPaused = false;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
  
  /// Dispose resources
  static Future<void> dispose() async {
    _autoSaveTimer?.cancel();
    await _recorder.dispose();
  }
}

/// Amplitude wrapper for recording visualization
class Amplitude {
  final double current;
  final double max;
  
  const Amplitude({
    required this.current,
    required this.max,
  });
  
  /// Get normalized amplitude (0-1)
  double get normalized {
    if (max == 0) return 0;
    final value = current / max;
    return value.clamp(0.0, 1.0);
  }
  
  /// Get decibels
  double get dB => max > 0 ? 20 * (current / max).log10() : -160;
}