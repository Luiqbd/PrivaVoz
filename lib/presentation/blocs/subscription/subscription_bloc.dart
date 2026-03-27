import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/subscription_service.dart';
import '../../../domain/entities/recording.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const SubscriptionState()) {
    on<CheckSubscriptionStatus>(_onCheckSubscriptionStatus);
    on<StartTrial>(_onStartTrial);
    on<PurchaseMonthly>(_onPurchaseMonthly);
    on<PurchaseYearly>(_onPurchaseYearly);
    on<RestorePurchases>(_onRestorePurchases);
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    try {
      final isTrialActive = await SubscriptionService.isTrialActive();
      final trialDaysRemaining = await SubscriptionService.getTrialDaysRemaining();
      final isSubscribed = await SubscriptionService.isSubscriptionActive();
      final subscriptionType = await SubscriptionService.getSubscriptionType();

      final isPremium = isSubscribed && 
          (subscriptionType == SubscriptionType.monthly || subscriptionType == SubscriptionType.yearly);

      SubscriptionStatus status;
      if (isPremium) {
        status = SubscriptionStatus.active;
      } else if (isTrialActive) {
        status = SubscriptionStatus.trial;
      } else {
        status = SubscriptionStatus.expired;
      }

      emit(state.copyWith(
        status: status,
        isTrialActive: isTrialActive,
        trialDaysRemaining: trialDaysRemaining,
        isPremium: isPremium,
        subscriptionType: subscriptionType.name,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStartTrial(
    StartTrial event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await SubscriptionService.activateTrial();
      add(const CheckSubscriptionStatus());
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseMonthly(
    PurchaseMonthly event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // In production, this would initiate in-app purchase
      // For demo, we simulate a successful purchase
      await SubscriptionService.activateSubscription(SubscriptionType.monthly);
      add(const CheckSubscriptionStatus());
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseYearly(
    PurchaseYearly event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // In production, this would initiate in-app purchase
      await SubscriptionService.activateSubscription(SubscriptionType.yearly);
      add(const CheckSubscriptionStatus());
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // In production, this would restore purchases from store
      add(const CheckSubscriptionStatus());
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}