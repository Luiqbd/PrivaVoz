import 'package:equatable/equatable.dart';

/// Recording Entity - Represents an audio recording
class Recording extends Equatable {
  final String id;
  final String name;
  final String filePath;
  final Duration duration;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEncrypted;
  final bool isInVault;
  final Transcription? transcription;
  final String? summary;
  final List<String>? tags;

  const Recording({
    required this.id,
    required this.name,
    required this.filePath,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
    this.isEncrypted = true,
    this.isInVault = false,
    this.transcription,
    this.summary,
    this.tags,
  });

  Recording copyWith({
    String? id,
    String? name,
    String? filePath,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEncrypted,
    bool? isInVault,
    Transcription? transcription,
    String? summary,
    List<String>? tags,
  }) {
    return Recording(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isInVault: isInVault ?? this.isInVault,
      transcription: transcription ?? this.transcription,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        filePath,
        duration,
        createdAt,
        updatedAt,
        isEncrypted,
        isInVault,
        transcription,
        summary,
        tags,
      ];
}

/// Transcription Entity - Represents a transcription with word-level timestamps
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
  List<Object?> get props => [
        id,
        recordingId,
        text,
        words,
        speakerSegments,
        createdAt,
        confidence,
      ];
}

/// TranscriptionWord - Individual word with timestamp
class TranscriptionWord extends Equatable {
  final String word;
  final double startTime; // in seconds
  final double endTime; // in seconds
  final int? speakerId;

  const TranscriptionWord({
    required this.word,
    required this.startTime,
    required this.endTime,
    this.speakerId,
  });

  @override
  List<Object?> get props => [word, startTime, endTime, speakerId];
}

/// SpeakerSegment - Segment of text from a specific speaker
class SpeakerSegment extends Equatable {
  final int speakerId;
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

/// Summary Entity - AI-generated summary
class Summary extends Equatable {
  final String id;
  final String recordingId;
  final String summaryText;
  final List<String> actionItems;
  final List<String> keywords;
  final DateTime createdAt;

  const Summary({
    required this.id,
    required this.recordingId,
    required this.summaryText,
    required this.actionItems,
    required this.keywords,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        recordingId,
        summaryText,
        actionItems,
        keywords,
        createdAt,
      ];
}

/// Subscription Entity - Subscription status
class Subscription extends Equatable {
  final SubscriptionType type;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;

  const Subscription({
    required this.type,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.trialEndDate,
  });

  bool get isTrial => type == SubscriptionType.trial;
  bool get isPremium => isActive && (type == SubscriptionType.monthly || type == SubscriptionType.yearly);
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());

  int get daysRemaining {
    if (trialEndDate != null) {
      return trialEndDate!.difference(DateTime.now()).inDays;
    }
    return 0;
  }

  @override
  List<Object?> get props => [type, isActive, startDate, endDate, trialEndDate];
}

/// Subscription Types
enum SubscriptionType {
  none,
  trial,
  monthly,
  yearly,
}

/// Recording Status
enum RecordingStatus {
  idle,
  recording,
  paused,
  saving,
  error,
}

/// Transcription Status
enum TranscriptionStatus {
  idle,
  processing,
  completed,
  error,
}

/// AI Processing Status
enum AIProcessingStatus {
  idle,
  transcribing,
  diarizing,
  summarizing,
  completed,
  error,
}