import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Biometric Authentication Service
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate with biometrics
  static Future<bool> authenticate({
    required String reason,
    String? title,
    String? subtitle,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        // Fallback to device PIN/password if biometric not available
        return await _localAuth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.message}');
      return false;
    }
  }

  /// Authenticate for vault access
  static Future<bool> authenticateForVault() async {
    return await authenticate(
      reason: 'Autentique para acessar o Cofre',
      title: 'PrivaVoz',
      subtitle: 'Use a biometria para acessar',
    );
  }

  /// Authenticate for app access
  static Future<bool> authenticateForApp() async {
    return await authenticate(
      reason: 'Autentique para acessar o PrivaVoz',
      title: 'PrivaVoz',
      subtitle: 'Acesso ao aplicativo',
    );
  }

  /// Check if vault is locked
  static Future<bool> isVaultLocked() async {
    final isLocked = await _secureStorage.read(key: 'vault_locked');
    return isLocked == 'true';
  }

  /// Set vault lock status
  static Future<void> setVaultLocked(bool locked) async {
    await _secureStorage.write(
      key: 'vault_locked',
      value: locked.toString(),
    );
  }

  /// Check if app requires authentication on launch
  static Future<bool> isAppAuthRequired() async {
    final requiresAuth = await _secureStorage.read(key: 'app_auth_required');
    return requiresAuth == 'true';
  }

  /// Set app authentication requirement
  static Future<void> setAppAuthRequired(bool required) async {
    await _secureStorage.write(
      key: 'app_auth_required',
      value: required.toString(),
    );
  }
}

/// Biometric types enum extension
extension BiometricTypeExtension on BiometricType {
  String get displayName {
    switch (this) {
      case BiometricType.fingerprint:
        return 'Impressão Digital';
      case BiometricType.face:
        return 'Reconhecimento Facial';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometria Forte';
      case BiometricType.weak:
        return 'Biometria Fraca';
      default:
        return 'Desconhecido';
    }
  }
}