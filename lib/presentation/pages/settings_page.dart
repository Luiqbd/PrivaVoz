import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/subscription_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/subscription/subscription_bloc.dart';
import '../blocs/subscription/subscription_event.dart';
import '../blocs/subscription/subscription_state.dart';
import '../widgets/glass_card.dart';
import 'subscription_page.dart';

/// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSubscriptionSection(context),
              const SizedBox(height: 16),
              _buildSecuritySection(context),
              const SizedBox(height: 16),
              _buildRecordingSection(),
              const SizedBox(height: 16),
              _buildAboutSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Personalize o PrivaVoz',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ASSINATURA',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionPage()),
            );
          },
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              return Row(
                children: [
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
                      state.isPremium ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: state.isPremium ? AppColors.neonMagenta : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isPremium ? 'Premium' : 'Teste Grátis',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.isTrialActive
                              ? '${state.trialDaysRemaining} dias restantes'
                              : state.isPremium
                                  ? 'Assinatura ativa'
                                  : 'Atualize para Premium',
                          style: TextStyle(
                            color: state.isTrialActive || state.isPremium
                                ? AppColors.neonGreen
                                : AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SEGURANÇA',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            context.read<AuthBloc>().add(const Authenticate(forVault: true));
            HapticFeedback.mediumImpact();
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cofre',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pastas privadas com biometria',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biometria',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Autenticação para acessar o app',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return Switch(
                    value: state.biometricsAvailable,
                    onChanged: (value) {
                      // Toggle biometric auth
                    },
                    activeColor: AppColors.neonCyan,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'GRAVAÇÃO',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.high_quality_rounded,
                title: 'Qualidade',
                subtitle: 'Alta (128 kbps)',
                onTap: () {},
              ),
              const Divider(color: AppColors.cardDark),
              _buildSettingTile(
                icon: Icons.timer_rounded,
                title: 'Auto-salvar',
                subtitle: 'A cada 30 segundos',
                onTap: () {},
              ),
              const Divider(color: AppColors.cardDark),
              _buildSettingTile(
                icon: Icons.mic_rounded,
                title: 'Formato',
                subtitle: 'M4A (AAC)',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SOBRE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.info_outline_rounded,
                title: 'Versão',
                subtitle: AppConstants.appVersion,
                onTap: () {},
              ),
              const Divider(color: AppColors.cardDark),
              _buildSettingTile(
                icon: Icons.shield_outlined,
                title: 'Privacidade',
                subtitle: '100% offline - sem dados coletados',
                onTap: () {},
              ),
              const Divider(color: AppColors.cardDark),
              _buildSettingTile(
                icon: Icons.cloud_off_rounded,
                title: 'Modo Offline',
                subtitle: 'Ativo - sem conexão necessária',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}