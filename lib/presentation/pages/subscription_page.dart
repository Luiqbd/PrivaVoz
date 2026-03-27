import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/subscription/subscription_bloc.dart';
import '../blocs/subscription/subscription_event.dart';
import '../blocs/subscription/subscription_state.dart';
import '../widgets/glass_card.dart';

/// Subscription Page - Paywall
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Assinatura',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                _buildHeader(state),
                const SizedBox(height: 32),
                
                // Trial badge (if applicable)
                if (state.isTrialActive) ...[
                  _buildTrialBadge(state),
                  const SizedBox(height: 24),
                ],
                
                // Monthly Plan
                _buildPlanCard(
                  context,
                  title: 'Mensal',
                  price: 'R\$ ${AppConstants.monthlyPrice.toStringAsFixed(2)}',
                  originalPrice: 'R\$ 39,90',
                  discount: '50% OFF',
                  features: [
                    'Transcrição com IA',
                    'Diarização de falantes',
                    'Resumos automáticos',
                    'Cofre biométrico',
                    'Gravação offline',
                  ],
                  isBestValue: false,
                  onTap: () {
                    _purchaseMonthly(context);
                  },
                ),
                const SizedBox(height: 16),
                
                // Yearly Plan
                _buildPlanCard(
                  context,
                  title: 'Anual',
                  price: 'R\$ ${AppConstants.yearlyPrice.toStringAsFixed(2)}',
                  originalPrice: 'R\$ 249,90',
                  discount: '40% OFF',
                  features: [
                    'Tudo do Plano Mensal',
                    'Economia de R\$ 239,90/ano',
                    'Prioridade no processamento',
                    'Suporte prioritário',
                  ],
                  isBestValue: true,
                  onTap: () {
                    _purchaseYearly(context);
                  },
                ),
                const SizedBox(height: 24),
                
                // Features list
                _buildFeaturesList(),
                const SizedBox(height: 16),
                
                // Restore purchases
                TextButton(
                  onPressed: () {
                    context.read<SubscriptionBloc>().add(const RestorePurchases());
                  },
                  child: Text(
                    'Restaurar compras',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SubscriptionState state) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.neonCyan.withValues(alpha: 0.3),
                AppColors.neonMagenta.withValues(alpha: 0.3),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.star_rounded,
            color: AppColors.neonMagenta,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Desbloqueie o Potencial Total',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Acesse todos os recursos de IA e tire\ntodo proveito do PrivaVoz',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrialBadge(SubscriptionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.2),
            AppColors.neonCyan.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: AppColors.neonGreen, size: 16),
          const SizedBox(width: 8),
          Text(
            'Trial: ${state.trialDaysRemaining} dias restantes',
            style: const TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String originalPrice,
    required String discount,
    required List<String> features,
    required bool isBestValue,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      borderColor: isBestValue ? AppColors.neonMagenta : null,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Best value badge
              if (isBestValue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.neonMagenta, AppColors.neonCyan],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    ' MELHOR VALOR ',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              // Title and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            originalPrice,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              discount,
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.neonGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 16),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBestValue ? AppColors.neonMagenta : AppColors.neonCyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isBestValue ? 'Assinar Anual' : 'Assinar Mensal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recursos Incluídos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.mic_rounded, 'Gravação de alta qualidade'),
          _buildFeatureRow(Icons.text_fields_rounded, 'Transcrição com IA'),
          _buildFeatureRow(Icons.people_rounded, 'Diarização de falantes'),
          _buildFeatureRow(Icons.summarize_rounded, 'Resumos automáticos'),
          _buildFeatureRow(Icons.lock_rounded, 'Cofre biométrico'),
          _buildFeatureRow(Icons.cloud_off_rounded, '100% Offline'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseMonthly(BuildContext context) {
    HapticFeedback.heavyImpact();
    context.read<SubscriptionBloc>().add(const PurchaseMonthly());
    _showSuccessDialog(context);
  }

  void _purchaseYearly(BuildContext context) {
    HapticFeedback.heavyImpact();
    context.read<SubscriptionBloc>().add(const PurchaseYearly());
    _showSuccessDialog(context);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.neonGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Assinatura Ativada!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obrigado por apoiar o PrivaVoz',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
              ),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}