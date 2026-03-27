import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/recording/recording_bloc.dart';
import '../blocs/recording/recording_event.dart';
import '../blocs/recording/recording_state.dart';
import '../blocs/subscription/subscription_bloc.dart';
import '../blocs/subscription/subscription_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/waveform_visualizer.dart';
import 'library_page.dart';
import 'settings_page.dart';
import 'subscription_page.dart';

/// Home Page - Main recording interface
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load recordings on start
    context.read<RecordingBloc>().add(const LoadRecordings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _RecordingTab(),
          LibraryPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.mic_rounded, 'Gravar'),
              _buildNavItem(1, Icons.library_music_rounded, 'Biblioteca'),
              _buildNavItem(2, Icons.settings_rounded, 'Config'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: AppColors.neonCyan),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recording Tab - Main recording interface
class _RecordingTab extends StatelessWidget {
  const _RecordingTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Status Header
          _buildStatusHeader(context),
          
          // Main Recording Area
          Expanded(
            child: BlocBuilder<RecordingBloc, RecordingState>(
              builder: (context, state) {
                return _buildRecordingArea(context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonCyan.withValues(alpha: 0.2),
                      AppColors.neonMagenta.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.neonCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'PrivaVoz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          // Status Badge
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.isPremium || state.isTrialActive
                        ? AppColors.neonGreen
                        : AppColors.neonOrange,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: state.isPremium || state.isTrialActive
                          ? AppColors.neonGreen
                          : AppColors.neonOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.isPremium
                          ? 'Premium'
                          : state.isTrialActive
                              ? 'Trial'
                              : 'Blindado',
                      style: TextStyle(
                        color: state.isPremium || state.isTrialActive
                            ? AppColors.neonGreen
                            : AppColors.neonOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingArea(BuildContext context, RecordingState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Waveform Visualizer
        WaveformVisualizer(
          amplitude: state.amplitude,
          isRecording: state.isRecording,
          isPaused: state.isPaused,
        ),
        
        const SizedBox(height: 32),
        
        // Duration Display
        _buildDurationDisplay(state),
        
        const SizedBox(height: 48),
        
        // Recording Controls
        _buildRecordingControls(context, state),
        
        const SizedBox(height: 24),
        
        // Subscription prompt if needed
        BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, subState) {
            if (!subState.canRecord && !state.isRecording) {
              return _buildSubscriptionPrompt(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildDurationDisplay(RecordingState state) {
    String durationText = '00:00:00';
    if (state.isRecording || state.isPaused) {
      final duration = state.currentDuration;
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      durationText = '$hours:$minutes:$seconds';
    }

    return Column(
      children: [
        Text(
          durationText,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: AppColors.textPrimary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isRecording
              ? 'Gravando...'
              : state.isPaused
                  ? 'Pausado'
                  : 'Toque para gravar',
          style: TextStyle(
            fontSize: 14,
            color: state.isRecording
                ? AppColors.neonCyan
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingControls(BuildContext context, RecordingState state) {
    final recordingBloc = context.read<RecordingBloc>();
    final isIdle = state.isIdle || state.status == RecordingStateStatus.loaded;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel Button (visible during recording)
        if (state.isRecording || state.isPaused) ...[
          _buildControlButton(
            icon: Icons.close_rounded,
            color: AppColors.error,
            onTap: () {
              HapticFeedback.heavyImpact();
              recordingBloc.add(const CancelRecording());
            },
          ),
          const SizedBox(width: 32),
        ],
        
        // Main Record Button
        NeonButton(
          onTap: () {
            HapticFeedback.heavyImpact();
            if (isIdle) {
              recordingBloc.add(const StartRecording());
            } else if (state.isRecording) {
              recordingBloc.add(const PauseRecording());
            } else if (state.isPaused) {
              recordingBloc.add(const ResumeRecording());
            } else {
              recordingBloc.add(const StopRecording());
            }
          },
          isRecording: state.isRecording,
          isPaused: state.isPaused,
          isLoading: state.status == RecordingStateStatus.saving,
        ),
        
        // Stop Button (visible during recording)
        if (state.isRecording || state.isPaused) ...[
          const SizedBox(width: 32),
          _buildControlButton(
            icon: Icons.stop_rounded,
            color: AppColors.neonCyan,
            onTap: () {
              HapticFeedback.heavyImpact();
              _showSaveDialog(context, recordingBloc);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, RecordingBloc bloc) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text(
          'Salvar Gravação',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Nome da gravação (opcional)',
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(StopRecording(name: controller.text.isNotEmpty ? controller.text : null));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonOrange.withValues(alpha: 0.2),
              AppColors.neonMagenta.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_rounded,
              color: AppColors.neonOrange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assinatura Expirada',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Toque para desbloquear',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.neonOrange,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}