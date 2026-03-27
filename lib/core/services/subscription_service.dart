import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/recording.dart';

/// Subscription Service - Handles trial and subscription management
class SubscriptionService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  /// Check if trial is active
  static Future<bool> isTrialActive() async {
    final trialStartStr = await _secureStorage.read(key: AppConstants.keyTrialStartDate);
    if (trialStartStr == null) return false;
    
    final trialStart = DateTime.parse(trialStartStr);
    final trialEnd = trialStart.add(Duration(days: AppConstants.trialDays));
    
    return DateTime.now().isBefore(trialEnd);
  }
  
  /// Activate trial (on first launch)
  static Future<void> activateTrial() async {
    final existingTrial = await _secureStorage.read(key: AppConstants.keyTrialActivated);
    if (existingTrial == 'true') return;
    
    final now = DateTime.now();
    await _secureStorage.write(
      key: AppConstants.keyTrialStartDate,
      value: now.toIso8601String(),
    );
    await _secureStorage.write(
      key: AppConstants.keyTrialActivated,
      value: 'true',
    );
  }
  
  /// Get trial days remaining
  static Future<int> getTrialDaysRemaining() async {
    final trialStartStr = await _secureStorage.read(key: AppConstants.keyTrialStartDate);
    if (trialStartStr == null) return 0;
    
    final trialStart = DateTime.parse(trialStartStr);
    final trialEnd = trialStart.add(Duration(days: AppConstants.trialDays));
    final remaining = trialEnd.difference(DateTime.now()).inDays;
    
    return remaining > 0 ? remaining : 0;
  }
  
  /// Check if user has active subscription
  static Future<bool> isSubscriptionActive() async {
    final isActive = await _secureStorage.read(key: AppConstants.keySubscriptionActive);
    return isActive == 'true';
  }
  
  /// Get subscription type
  static Future<SubscriptionType> getSubscriptionType() async {
    final typeStr = await _secureStorage.read(key: AppConstants.keySubscriptionType);
    if (typeStr == null) return SubscriptionType.none;
    
    switch (typeStr) {
      case 'trial':
        return SubscriptionType.trial;
      case 'monthly':
        return SubscriptionType.monthly;
      case 'yearly':
        return SubscriptionType.yearly;
      default:
        return SubscriptionType.none;
    }
  }
  
  /// Activate subscription (mock - in production would validate receipt)
  static Future<void> activateSubscription(SubscriptionType type) async {
    await _secureStorage.write(
      key: AppConstants.keySubscriptionActive,
      value: 'true',
    );
    await _secureStorage.write(
      key: AppConstants.keySubscriptionType,
      value: type.name,
    );
  }
  
  /// Cancel subscription
  static Future<void> cancelSubscription() async {
    await _secureStorage.write(
      key: AppConstants.keySubscriptionActive,
      value: 'false',
    );
    await _secureStorage.write(
      key: AppConstants.keySubscriptionType,
      value: SubscriptionType.none.name,
    );
  }
  
  /// Check if user can access premium features
  static Future<bool> canAccessPremium() async {
    // Check subscription first
    final isSubscribed = await isSubscriptionActive();
    if (isSubscribed) return true;
    
    // Check trial
    final isTrial = await isTrialActive();
    return isTrial;
  }
  
  /// Check if user can record (requires active trial/subscription)
  static Future<bool> canRecord() async {
    return await canAccessPremium();
  }
  
  /// Check if user can use AI features
  static Future<bool> canUseAI() async {
    return await canAccessPremium();
  }
  
  /// Get subscription info
  static Future<Subscription> getSubscriptionInfo() async {
    final isActive = await isSubscriptionActive();
    final type = await getSubscriptionType();
    final trialRemaining = await getTrialDaysRemaining();
    
    return Subscription(
      type: type,
      isActive: isActive || await isTrialActive(),
      trialEndDate: type == SubscriptionType.trial 
          ? DateTime.now().add(Duration(days: trialRemaining))
          : null,
    );
  }
  
  /// Reset subscription (for testing)
  static Future<void> reset() async {
    await _secureStorage.delete(key: AppConstants.keyTrialStartDate);
    await _secureStorage.delete(key: AppConstants.keyTrialActivated);
    await _secureStorage.delete(key: AppConstants.keySubscriptionActive);
    await _secureStorage.delete(key: AppConstants.keySubscriptionType);
  }
}