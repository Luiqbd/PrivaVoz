import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';

/// Encryption Service - AES-256 for audio and text encryption
class EncryptionService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static encrypt.Key? _key;
  static encrypt.IV? _iv;
  static bool _initialized = false;

  /// Initialize encryption keys
  static Future<void> init() async {
    if (_initialized) return;

    // Try to load existing key and IV
    String? storedKey = await _secureStorage.read(key: AppConstants.encryptionKeyName);
    String? storedIV = await _secureStorage.read(key: AppConstants.encryptionIVName);

    if (storedKey != null && storedIV != null) {
      _key = encrypt.Key.fromBase64(storedKey);
      _iv = encrypt.IV.fromBase64(storedIV);
    } else {
      // Generate new key and IV
      _key = encrypt.Key.fromSecureRandom(32); // 256-bit key
      _iv = encrypt.IV.fromSecureRandom(16); // 128-bit IV

      // Store them securely
      await _secureStorage.write(
        key: AppConstants.encryptionKeyName,
        value: _key!.base64,
      );
      await _secureStorage.write(
        key: AppConstants.encryptionIVName,
        value: _iv!.base64,
      );
    }

    _initialized = true;
  }

  /// Encrypt data
  static Future<Uint8List> encryptData(Uint8List data) async {
    if (!_initialized) await init();

    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encryptBytes(data, iv: _iv);
    return encrypted.bytes;
  }

  /// Decrypt data
  static Future<Uint8List> decryptData(Uint8List encryptedData) async {
    if (!_initialized) await init();

    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypt.Encrypted(encryptedData);
    final decrypted = encrypter.decryptBytes(encrypted, iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  /// Encrypt string
  static Future<String> encryptString(String text) async {
    if (!_initialized) await init();

    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt string
  static Future<String> decryptString(String encryptedText) async {
    if (!_initialized) await init();

    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );

    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  /// Check if encryption is initialized
  static bool get isInitialized => _initialized;

  /// Reset encryption (for testing/reset)
  static Future<void> reset() async {
    await _secureStorage.delete(key: AppConstants.encryptionKeyName);
    await _secureStorage.delete(key: AppConstants.encryptionIVName);
    _key = null;
    _iv = null;
    _initialized = false;
  }
}