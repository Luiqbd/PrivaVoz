import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/biometric_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<Authenticate>(_onAuthenticate);
    on<LockVault>(_onLockVault);
    on<UnlockVault>(_onUnlockVault);
    on<CheckBiometrics>(_onCheckBiometrics);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking));

    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isVaultLocked = await BiometricService.isVaultLocked();

      emit(state.copyWith(
        status: isVaultLocked ? AuthStatus.vaultLocked : AuthStatus.unauthenticated,
        biometricsAvailable: isAvailable,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    try {
      bool success;
      if (event.forVault) {
        success = await BiometricService.authenticateForVault();
      } else {
        success = await BiometricService.authenticateForApp();
      }

      if (success) {
        if (event.forVault) {
          await BiometricService.setVaultLocked(false);
          emit(state.copyWith(status: AuthStatus.vaultUnlocked));
        } else {
          emit(state.copyWith(status: AuthStatus.authenticated));
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Autenticação falhou',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLockVault(
    LockVault event,
    Emitter<AuthState> emit,
  ) async {
    await BiometricService.setVaultLocked(true);
    emit(state.copyWith(status: AuthStatus.vaultLocked));
  }

  Future<void> _onUnlockVault(
    UnlockVault event,
    Emitter<AuthState> emit,
  ) async {
    final success = await BiometricService.authenticateForVault();
    if (success) {
      await BiometricService.setVaultLocked(false);
      emit(state.copyWith(status: AuthStatus.vaultUnlocked));
    }
  }

  Future<void> _onCheckBiometrics(
    CheckBiometrics event,
    Emitter<AuthState> emit,
  ) async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    emit(state.copyWith(biometricsAvailable: isAvailable));
  }
}