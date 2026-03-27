import 'package:equatable/equatable.dart';

/// Subscription State Status
enum SubscriptionStatus {
  initial,
  loading,
  active,
  trial,
  expired,
  error,
}

/// Subscription State
class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final bool isTrialActive;
  final int trialDaysRemaining;
  final bool isPremium;
  final String? subscriptionType;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.isTrialActive = false,
    this.trialDaysRemaining = 0,
    this.isPremium = false,
    this.subscriptionType,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    bool? isTrialActive,
    int? trialDaysRemaining,
    bool? isPremium,
    String? subscriptionType,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      isPremium: isPremium ?? this.isPremium,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get canRecord => isTrialActive || isPremium;
  bool get canUseAI => isTrialActive || isPremium;

  @override
  List<Object?> get props => [
        status,
        isTrialActive,
        trialDaysRemaining,
        isPremium,
        subscriptionType,
        errorMessage,
      ];
}