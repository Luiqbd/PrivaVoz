import 'package:equatable/equatable.dart';

/// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check auth status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Authenticate with biometrics
class Authenticate extends AuthEvent {
  final bool forVault;

  const Authenticate({this.forVault = false});

  @override
  List<Object?> get props => [forVault];
}

/// Lock vault
class LockVault extends AuthEvent {
  const LockVault();
}

/// Unlock vault
class UnlockVault extends AuthEvent {
  const UnlockVault();
}

/// Check if biometrics available
class CheckBiometrics extends AuthEvent {
  const CheckBiometrics();
}