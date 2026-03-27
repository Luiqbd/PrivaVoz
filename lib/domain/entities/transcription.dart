import 'package:equatable/equatable.dart';

/// Transcription word with timestamp
class TranscriptionWord extends Equatable {
  final String word;
  final double startTime;
  final double endTime;
  final String? speakerId;

  const TranscriptionWord({
    required this.word,
    required this.startTime,
    required this.endTime,
    this.speakerId,
  });

  @override
  List<Object?> get props => [word, startTime, endTime, speakerId];
}

/// Speaker segment in transcription
class SpeakerSegment extends Equatable {
  final String speakerId;
  final String speakerLabel;
  final double startTime;
  final double endTime;
  final String text;

  const SpeakerSegment({
    required this.speakerId,
    required this.speakerLabel,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  @override
  List<Object?> get props => [speakerId, speakerLabel, startTime, endTime, text];
}

/// Transcription entity
class Transcription extends Equatable {
  final String id;
  final String recordingId;
  final String text;
  final List<TranscriptionWord> words;
  final List<SpeakerSegment> speakerSegments;
  final DateTime createdAt;
  final double confidence;

  const Transcription({
    required this.id,
    required this.recordingId,
    required this.text,
    required this.words,
    required this.speakerSegments,
    required this.createdAt,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [id, recordingId, text, words, speakerSegments, createdAt, confidence];
}