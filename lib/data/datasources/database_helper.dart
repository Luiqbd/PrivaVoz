import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../../domain/entities/recording.dart';

/// Database helper for local storage
class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'privavoz.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableRecordings = 'recordings';
  static const String tableTranscriptions = 'transcriptions';
  static const String tableSummaries = 'summaries';

  /// Get database instance (singleton)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Recordings table
    await db.execute('''
      CREATE TABLE $tableRecordings (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        duration INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_encrypted INTEGER NOT NULL DEFAULT 1,
        is_in_vault INTEGER NOT NULL DEFAULT 0,
        transcription_id TEXT,
        summary TEXT,
        tags TEXT
      )
    ''');

    // Transcriptions table
    await db.execute('''
      CREATE TABLE $tableTranscriptions (
        id TEXT PRIMARY KEY,
        recording_id TEXT NOT NULL,
        text TEXT NOT NULL,
        words TEXT NOT NULL,
        speaker_segments TEXT,
        created_at TEXT NOT NULL,
        confidence REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (recording_id) REFERENCES $tableRecordings (id) ON DELETE CASCADE
      )
    ''');

    // Summaries table
    await db.execute('''
      CREATE TABLE $tableSummaries (
        id TEXT PRIMARY KEY,
        recording_id TEXT NOT NULL,
        summary_text TEXT NOT NULL,
        action_items TEXT,
        keywords TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (recording_id) REFERENCES $tableRecordings (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_recordings_created_at ON $tableRecordings (created_at DESC)');
    await db.execute('CREATE INDEX idx_recordings_is_in_vault ON $tableRecordings (is_in_vault)');
    await db.execute('CREATE INDEX idx_transcriptions_recording_id ON $tableTranscriptions (recording_id)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  // ==================== RECORDINGS ====================

  /// Insert a new recording
  Future<void> insertRecording(Recording recording) async {
    final db = await database;
    await db.insert(
      tableRecordings,
      {
        'id': recording.id,
        'name': recording.name,
        'file_path': recording.filePath,
        'duration': recording.duration.inMilliseconds,
        'created_at': recording.createdAt.toIso8601String(),
        'updated_at': recording.updatedAt?.toIso8601String(),
        'is_encrypted': recording.isEncrypted ? 1 : 0,
        'is_in_vault': recording.isInVault ? 1 : 0,
        'transcription_id': recording.transcription?.id,
        'summary': recording.summary,
        'tags': recording.tags != null ? jsonEncode(recording.tags) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all recordings
  Future<List<Recording>> getAllRecordings({bool includeVault = true}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableRecordings,
      where: includeVault ? null : 'is_in_vault = ?',
      whereArgs: includeVault ? null : [0],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _recordingFromMap(map)).toList();
  }

  /// Get recordings in vault
  Future<List<Recording>> getVaultRecordings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableRecordings,
      where: 'is_in_vault = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _recordingFromMap(map)).toList();
  }

  /// Get recording by ID
  Future<Recording?> getRecordingById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableRecordings,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _recordingFromMap(maps.first);
  }

  /// Update recording
  Future<void> updateRecording(Recording recording) async {
    final db = await database;
    await db.update(
      tableRecordings,
      {
        'name': recording.name,
        'updated_at': DateTime.now().toIso8601String(),
        'is_in_vault': recording.isInVault ? 1 : 0,
        'transcription_id': recording.transcription?.id,
        'summary': recording.summary,
        'tags': recording.tags != null ? jsonEncode(recording.tags) : null,
      },
      where: 'id = ?',
      whereArgs: [recording.id],
    );
  }

  /// Delete recording
  Future<void> deleteRecording(String id) async {
    final db = await database;
    await db.delete(
      tableRecordings,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Move recording to/from vault
  Future<void> moveToVault(String id, bool toVault) async {
    final db = await database;
    await db.update(
      tableRecordings,
      {
        'is_in_vault': toVault ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== TRANSCRIPTIONS ====================

  /// Insert transcription
  Future<void> insertTranscription(Transcription transcription) async {
    final db = await database;
    await db.insert(
      tableTranscriptions,
      {
        'id': transcription.id,
        'recording_id': transcription.recordingId,
        'text': transcription.text,
        'words': jsonEncode(transcription.words.map((w) => {
          return {
            'word': w.word,
            'start_time': w.startTime,
            'end_time': w.endTime,
            'speaker_id': w.speakerId,
          };
        }).toList()),
        'speaker_segments': jsonEncode(transcription.speakerSegments.map((s) => {
          return {
            'speaker_id': s.speakerId,
            'speaker_label': s.speakerLabel,
            'start_time': s.startTime,
            'end_time': s.endTime,
            'text': s.text,
          };
        }).toList()),
        'created_at': transcription.createdAt.toIso8601String(),
        'confidence': transcription.confidence,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get transcription by recording ID
  Future<Transcription?> getTranscriptionByRecordingId(String recordingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTranscriptions,
      where: 'recording_id = ?',
      whereArgs: [recordingId],
    );

    if (maps.isEmpty) return null;
    return _transcriptionFromMap(maps.first);
  }

  // ==================== SUMMARIES ====================

  /// Insert summary
  Future<void> insertSummary(Summary summary) async {
    final db = await database;
    await db.insert(
      tableSummaries,
      {
        'id': summary.id,
        'recording_id': summary.recordingId,
        'summary_text': summary.summaryText,
        'action_items': jsonEncode(summary.actionItems),
        'keywords': jsonEncode(summary.keywords),
        'created_at': summary.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get summary by recording ID
  Future<Summary?> getSummaryByRecordingId(String recordingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSummaries,
      where: 'recording_id = ?',
      whereArgs: [recordingId],
    );

    if (maps.isEmpty) return null;
    return _summaryFromMap(maps.first);
  }

  // ==================== HELPERS ====================

  Recording _recordingFromMap(Map<String, dynamic> map) {
    Transcription? transcription;
    if (map['transcription_id'] != null) {
      // Would need to fetch transcription separately
    }

    return Recording(
      id: map['id'] as String,
      name: map['name'] as String,
      filePath: map['file_path'] as String,
      duration: Duration(milliseconds: map['duration'] as int),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      isEncrypted: (map['is_encrypted'] as int) == 1,
      isInVault: (map['is_in_vault'] as int) == 1,
      summary: map['summary'] as String?,
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'] as String)) : null,
    );
  }

  Transcription _transcriptionFromMap(Map<String, dynamic> map) {
    final wordsData = jsonDecode(map['words'] as String) as List;
    final words = wordsData.map((w) => TranscriptionWord(
      word: w['word'] as String,
      startTime: (w['start_time'] as num).toDouble(),
      endTime: (w['end_time'] as num).toDouble(),
      speakerId: w['speaker_id'] as int?,
    )).toList();

    List<SpeakerSegment> speakerSegments = [];
    if (map['speaker_segments'] != null) {
      final segmentsData = jsonDecode(map['speaker_segments'] as String) as List;
      speakerSegments = segmentsData.map((s) => SpeakerSegment(
        speakerId: s['speaker_id'] as int,
        speakerLabel: s['speaker_label'] as String,
        startTime: (s['start_time'] as num).toDouble(),
        endTime: (s['end_time'] as num).toDouble(),
        text: s['text'] as String,
      )).toList();
    }

    return Transcription(
      id: map['id'] as String,
      recordingId: map['recording_id'] as String,
      text: map['text'] as String,
      words: words,
      speakerSegments: speakerSegments,
      createdAt: DateTime.parse(map['created_at'] as String),
      confidence: (map['confidence'] as num).toDouble(),
    );
  }

  Summary _summaryFromMap(Map<String, dynamic> map) {
    return Summary(
      id: map['id'] as String,
      recordingId: map['recording_id'] as String,
      summaryText: map['summary_text'] as String,
      actionItems: List<String>.from(jsonDecode(map['action_items'] as String)),
      keywords: List<String>.from(jsonDecode(map['keywords'] as String)),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}