import 'package:equatable/equatable.dart';

/// Recording Events
abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

/// Start recording
class StartRecording extends RecordingEvent {
  const StartRecording();
}

/// Pause recording
class PauseRecording extends RecordingEvent {
  const PauseRecording();
}

/// Resume recording
class ResumeRecording extends RecordingEvent {
  const ResumeRecording();
}

/// Stop recording
class StopRecording extends RecordingEvent {
  final String? name;

  const StopRecording({this.name});

  @override
  List<Object?> get props => [name];
}

/// Cancel recording
class CancelRecording extends RecordingEvent {
  const CancelRecording();
}

/// Update duration (internal timer tick)
class UpdateDuration extends RecordingEvent {
  const UpdateDuration();
}

/// Update amplitude (for visualization)
class UpdateAmplitude extends RecordingEvent {
  final double amplitude;

  const UpdateAmplitude(this.amplitude);

  @override
  List<Object?> get props => [amplitude];
}

/// Load recordings from database
class LoadRecordings extends RecordingEvent {
  const LoadRecordings();
}

/// Delete recording
class DeleteRecording extends RecordingEvent {
  final String recordingId;

  const DeleteRecording(this.recordingId);

  @override
  List<Object?> get props => [recordingId];
}

/// Move recording to/from vault
class MoveToVault extends RecordingEvent {
  final String recordingId;
  final bool toVault;

  const MoveToVault(this.recordingId, this.toVault);

  @override
  List<Object?> get props => [recordingId, toVault];
}

/// Rename recording
class RenameRecording extends RecordingEvent {
  final String recordingId;
  final String newName;

  const RenameRecording(this.recordingId, this.newName);

  @override
  List<Object?> get props => [recordingId, newName];
}