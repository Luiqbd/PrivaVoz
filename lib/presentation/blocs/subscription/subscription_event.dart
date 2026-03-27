import 'package:equatable/equatable.dart';

/// Subscription Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Check subscription status
class CheckSubscriptionStatus extends SubscriptionEvent {
  const CheckSubscriptionStatus();
}

/// Start trial
class StartTrial extends SubscriptionEvent {
  const StartTrial();
}

/// Purchase monthly subscription
class PurchaseMonthly extends SubscriptionEvent {
  const PurchaseMonthly();
}

/// Purchase yearly subscription
class PurchaseYearly extends SubscriptionEvent {
  const PurchaseYearly();
}

/// Restore purchases
class RestorePurchases extends SubscriptionEvent {
  const RestorePurchases();
}