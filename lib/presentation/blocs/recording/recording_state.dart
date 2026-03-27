import 'package:equatable/equatable.dart';
import '../../../domain/entities/recording.dart';

/// Recording State Status
enum RecordingStateStatus {
  initial,
  idle,
  recording,
  paused,
  saving,
  loading,
  loaded,
  error,
}

/// Recording State
class RecordingState extends Equatable {
  final RecordingStateStatus status;
  final Duration currentDuration;
  final double amplitude;
  final List<Recording> recordings;
  final String? errorMessage;
  final String? lastRecordingPath;

  const RecordingState({
    this.status = RecordingStateStatus.initial,
    this.currentDuration = Duration.zero,
    this.amplitude = 0.0,
    this.recordings = const [],
    this.errorMessage,
    this.lastRecordingPath,
  });

  RecordingState copyWith({
    RecordingStateStatus? status,
    Duration? currentDuration,
    double? amplitude,
    List<Recording>? recordings,
    String? errorMessage,
    String? lastRecordingPath,
  }) {
    return RecordingState(
      status: status ?? this.status,
      currentDuration: currentDuration ?? this.currentDuration,
      amplitude: amplitude ?? this.amplitude,
      recordings: recordings ?? this.recordings,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRecordingPath: lastRecordingPath ?? this.lastRecordingPath,
    );
  }

  /// Check if recording is in progress
  bool get isRecording => status == RecordingStateStatus.recording;
  bool get isPaused => status == RecordingStateStatus.paused;
  bool get isIdle => status == RecordingStateStatus.idle || status == RecordingStateStatus.initial;
  bool get isLoading => status == RecordingStateStatus.loading || status == RecordingStateStatus.saving;
  bool get hasError => status == RecordingStateStatus.error;
  bool get hasRecordings => recordings.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        currentDuration,
        amplitude,
        recordings,
        errorMessage,
        lastRecordingPath,
      ];
}