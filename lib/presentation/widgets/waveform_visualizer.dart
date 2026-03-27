import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Waveform Visualizer - Animated organic waveform
class WaveformVisualizer extends StatefulWidget {
  final double amplitude;
  final bool isRecording;
  final bool isPaused;

  const WaveformVisualizer({
    super.key,
    this.amplitude = 0.0,
    this.isRecording = false,
    this.isPaused = false,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _waveHeights = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Initialize wave heights
    for (int i = 0; i < 40; i++) {
      _waveHeights.add(0.1 + _random.nextDouble() * 0.2);
    }

    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _WaveformPainter(
              waveHeights: _waveHeights,
              amplitude: widget.amplitude,
              isRecording: widget.isRecording,
              isPaused: widget.isPaused,
              animationValue: _controller.value,
              random: _random,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveHeights;
  final double amplitude;
  final bool isRecording;
  final bool isPaused;
  final double animationValue;
  final Random random;

  _WaveformPainter({
    required this.waveHeights,
    required this.amplitude,
    required this.isRecording,
    required this.isPaused,
    required this.animationValue,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveHeights.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = size.width / waveHeights.length;

    // Update wave heights when recording
    List<double> heights = List.from(waveHeights);
    if (isRecording && !isPaused) {
      for (int i = 0; i < heights.length; i++) {
        // Add organic variation based on animation
        final variation = sin((animationValue * 2 * pi) + (i * 0.3)).abs() * 0.3;
        final targetHeight = 0.3 + (amplitude * 0.5) + variation;
        heights[i] = heights[i] + (targetHeight - heights[i]) * 0.3;
      }
    }

    for (int i = 0; i < heights.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final height = heights[i] * size.height * 0.8;

      // Create gradient for each bar
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isRecording
            ? [
                AppColors.neonCyan,
                AppColors.neonMagenta,
              ]
            : [
                AppColors.textMuted.withValues(alpha: 0.3),
                AppColors.textMuted.withValues(alpha: 0.1),
              ],
      );

      paint.shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth * 0.6,
          height: height,
        ),
      );

      // Draw symmetrical bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth * 0.5,
          height: height,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }

    // Draw glow effect when recording
    if (isRecording && !isPaused) {
      final glowPaint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.isRecording != isRecording ||
        oldDelegate.isPaused != isPaused;
  }
}