import 'package:equatable/equatable.dart';

/// Auth State Status
enum AuthStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
  vaultLocked,
  vaultUnlocked,
  biometricsUnavailable,
  error,
}

/// Auth State
class AuthState extends Equatable {
  final AuthStatus status;
  final bool biometricsAvailable;
  final bool isAppLocked;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.biometricsAvailable = false,
    this.isAppLocked = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? biometricsAvailable,
    bool? isAppLocked,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
      isAppLocked: isAppLocked ?? this.isAppLocked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isVaultUnlocked => status == AuthStatus.vaultUnlocked;

  @override
  List<Object?> get props => [status, biometricsAvailable, isAppLocked, errorMessage];
}