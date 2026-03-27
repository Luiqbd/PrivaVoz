import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/recording.dart';
import '../widgets/glass_card.dart';

/// Player Page - Audio player with karaokê effect
class PlayerPage extends StatefulWidget {
  final Recording recording;

  const PlayerPage({
    super.key,
    required this.recording,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  // Mock transcription for demo
  final List<TranscriptionWord> _words = _generateMockWords();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.recording.filePath);
      _totalDuration = _audioPlayer.duration ?? Duration.zero;
      
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });
      
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.recording.name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Waveform visualization
          _buildWaveform(),
          
          // Playback controls
          _buildPlaybackControls(),
          
          // Transcription / Karaokê
          Expanded(
            child: _buildTranscription(),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _WaveformPainter(
            progress: _totalDuration.inMilliseconds > 0
                ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                : 0,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.neonCyan,
              inactiveTrackColor: AppColors.cardDark,
              thumbColor: AppColors.neonCyan,
              overlayColor: AppColors.neonCyan.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _currentPosition.inMilliseconds.toDouble(),
              min: 0,
              max: _totalDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Playback buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                color: AppColors.textSecondary,
                iconSize: 32,
                onPressed: () {
                  final newPos = _currentPosition - const Duration(seconds: 10);
                  _audioPlayer.seek(newPos > Duration.zero ? newPos : Duration.zero);
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (_isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonCyan,
                        AppColors.neonMagenta,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.primaryDark,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                color: AppColors.textSecondary,
                iconSize: 32,
                onPressed: () {
                  final newPos = _currentPosition + const Duration(seconds: 10);
                  _audioPlayer.seek(newPos < _totalDuration ? newPos : _totalDuration);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscription() {
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transcrição',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.translate_rounded, size: 20),
                      color: AppColors.neonCyan,
                      onPressed: () {
                        // TODO: Transcribe
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.summarize_rounded, size: 20),
                      color: AppColors.neonMagenta,
                      onPressed: () {
                        // TODO: Summarize
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Karaokê text
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _words.map((word) {
                  final isActive = _isWordActive(word);
                  return GestureDetector(
                    onTap: () {
                      _audioPlayer.seek(Duration(milliseconds: (word.startTime * 1000).toInt()));
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.neonCyan.withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: isActive
                            ? Border.all(color: AppColors.neonCyan)
                            : null,
                      ),
                      child: Text(
                        word.word,
                        style: TextStyle(
                          color: isActive ? AppColors.neonCyan : AppColors.textPrimary,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isWordActive(TranscriptionWord word) {
    final currentSeconds = _currentPosition.inMilliseconds / 1000;
    return currentSeconds >= word.startTime && currentSeconds <= word.endTime;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Waveform painter
class _WaveformPainter extends CustomPainter {
  final double progress;

  _WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    const barWidth = 3.0;
    const barSpacing = 4.0;
    final barCount = (size.width / (barWidth + barSpacing)).floor();

    for (var i = 0; i < barCount; i++) {
      final x = i * (barWidth + barSpacing);
      final progressPos = progress * barCount;
      
      // Generate pseudo-random heights
      final height = (size.height * 0.3) + 
          (size.height * 0.4 * ((i * 17 % 31) / 31));
      
      if (i < progressPos) {
        paint.color = AppColors.neonCyan;
      } else {
        paint.color = AppColors.textMuted.withValues(alpha: 0.3);
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, centerY),
            width: barWidth,
            height: height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Generate mock transcription words
List<TranscriptionWord> _generateMockWords() {
  return [
    const TranscriptionWord(word: 'Olá', startTime: 0.0, endTime: 0.5, speakerId: 1),
    const TranscriptionWord(word: 'pessoal', startTime: 0.5, endTime: 1.0, speakerId: 1),
    const TranscriptionWord(word: 'sejam', startTime: 1.0, endTime: 1.3, speakerId: 1),
    const TranscriptionWord(word: 'bem', startTime: 1.3, endTime: 1.6, speakerId: 1),
    const TranscriptionWord(word: 'vindos', startTime: 1.6, endTime: 2.0, speakerId: 1),
    const TranscriptionWord(word: 'à', startTime: 2.0, endTime: 2.2, speakerId: 1),
    const TranscriptionWord(word: 'nossa', startTime: 2.2, endTime: 2.5, speakerId: 1),
    const TranscriptionWord(word: 'reunião', startTime: 2.5, endTime: 3.0, speakerId: 1),
    const TranscriptionWord(word: 'de', startTime: 3.0, endTime: 3.2, speakerId: 1),
    const TranscriptionWord(word: 'hoje', startTime: 3.2, endTime: 3.5, speakerId: 1),
    const TranscriptionWord(word: 'Vamos', startTime: 4.0, endTime: 4.3, speakerId: 2),
    const TranscriptionWord(word: 'discutir', startTime: 4.3, endTime: 4.7, speakerId: 2),
    const TranscriptionWord(word: 'os', startTime: 4.7, endTime: 4.9, speakerId: 2),
    const TranscriptionWord(word: 'projetos', startTime: 4.9, endTime: 5.4, speakerId: 2),
    const TranscriptionWord(word: 'da', startTime: 5.4, endTime: 5.6, speakerId: 2),
    const TranscriptionWord(word: 'semana', startTime: 5.6, endTime: 6.0, speakerId: 2),
    const TranscriptionWord(word: 'sim', startTime: 7.0, endTime: 7.3, speakerId: 1),
    const TranscriptionWord(word: 'concordo', startTime: 7.3, endTime: 7.8, speakerId: 1),
    const TranscriptionWord(word: 'precisamos', startTime: 7.8, endTime: 8.3, speakerId: 1),
    const TranscriptionWord(word: 'revisar', startTime: 8.3, endTime: 8.7, speakerId: 1),
    const TranscriptionWord(word: 'o', startTime: 8.7, endTime: 8.8, speakerId: 1),
    const TranscriptionWord(word: 'cronograma', startTime: 8.8, endTime: 9.4, speakerId: 1),
  ];
}