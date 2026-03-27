import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Neon Button - Glowing button with animation
class NeonButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isRecording;
  final bool isPaused;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.onTap,
    this.isRecording = false,
    this.isPaused = false,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isRecording
                      ? [AppColors.neonCyan, AppColors.neonMagenta]
                      : widget.isPaused
                          ? [AppColors.neonOrange, AppColors.neonOrange]
                          : [AppColors.neonCyan.withValues(alpha: 0.8), AppColors.neonCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppColors.neonCyan
                            : widget.isPaused
                                ? AppColors.neonOrange
                                : AppColors.neonCyan)
                        .withValues(alpha: 0.6),
                    blurRadius: widget.isRecording ? 30 : 20,
                    spreadRadius: widget.isRecording ? 5 : 2,
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryDark,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Icon(
                      widget.isRecording
                          ? Icons.pause_rounded
                          : widget.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.mic_rounded,
                      color: AppColors.primaryDark,
                      size: 40,
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Icon Button with neon glow
class NeonIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}