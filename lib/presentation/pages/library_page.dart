import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/recording.dart';
import '../blocs/recording/recording_bloc.dart';
import '../blocs/recording/recording_event.dart';
import '../blocs/recording/recording_state.dart';
import '../blocs/subscription/subscription_bloc.dart';
import '../blocs/subscription/subscription_state.dart';
import '../widgets/glass_card.dart';
import 'player_page.dart';
import 'subscription_page.dart';

/// Library Page - Shows all recordings
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<RecordingBloc, RecordingState>(
                builder: (context, state) {
                  if (state.status == RecordingStateStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonCyan,
                      ),
                    );
                  }

                  if (state.recordings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildRecordingsList(context, state.recordings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biblioteca',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Suas gravações',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_rounded,
                      size: 14,
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${context.watch<RecordingBloc>().state.recordings.length}',
                      style: const TextStyle(
                        color: AppColors.neonCyan,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off_rounded,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma gravação',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grave sua primeira áudio',
            style: TextStyle(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsList(BuildContext context, List<Recording> recordings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final recording = recordings[index];
        return _RecordingTile(
          recording: recording,
          onTap: () => _openPlayer(context, recording),
          onDelete: () => _confirmDelete(context, recording),
          onMoveToVault: () => _toggleVault(context, recording),
        );
      },
    );
  }

  void _openPlayer(BuildContext context, Recording recording) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(recording: recording),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Recording recording) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text(
          'Excluir Gravação?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.textSecondary),
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
              context.read<RecordingBloc>().add(DeleteRecording(recording.id));
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _toggleVault(BuildContext context, Recording recording) {
    context.read<RecordingBloc>().add(
      MoveToVault(recording.id, !recording.isInVault),
    );
    HapticFeedback.mediumImpact();
  }
}

class _RecordingTile extends StatelessWidget {
  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMoveToVault;

  const _RecordingTile({
    required this.recording,
    required this.onTap,
    required this.onDelete,
    required this.onMoveToVault,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Recording Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonCyan.withValues(alpha: 0.3),
                    AppColors.neonMagenta.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                recording.isInVault
                    ? Icons.lock_rounded
                    : Icons.mic_rounded,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(width: 16),
            
            // Recording Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(recording.duration),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(recording.createdAt),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textMuted,
              ),
              color: AppColors.surfaceDark,
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    onDelete();
                    break;
                  case 'vault':
                    onMoveToVault();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'vault',
                  child: Row(
                    children: [
                      Icon(
                        recording.isInVault
                            ? Icons.lock_open_rounded
                            : Icons.lock_rounded,
                        color: AppColors.neonCyan,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        recording.isInVault ? 'Remover do Cofre' : 'Mover para Cofre',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Excluir',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hoje';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}