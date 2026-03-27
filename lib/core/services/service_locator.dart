import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/database_helper.dart';
import 'ai_service.dart';
import 'encryption_service.dart';
import 'subscription_service.dart';

/// Service Locator - Simple dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  bool _initialized = false;

  /// Initialize all services
  static Future<void> init() async {
    if (_instance._initialized) return;

    // Initialize Flutter Secure Storage
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );

    // Register services
    _instance._services[FlutterSecureStorage] = secureStorage;
    _instance._services[DatabaseHelper] = DatabaseHelper();

    // Initialize encryption
    await EncryptionService.init();

    // Initialize AI service (loads models from assets)
    await AIService.initialize();

    // Initialize subscription service (activate trial if first launch)
    await SubscriptionService.activateTrial();

    _instance._initialized = true;
    print('[ServiceLocator] All services initialized');
  }

  /// Get a service by type
  static T get<T>() {
    final service = _instance._services[T];
    if (service == null) {
      throw Exception('Service $T not registered');
    }
    return service as T;
  }

  /// Register a service
  static void register<T>(T service) {
    _instance._services[T] = service;
  }

  /// Check if a service is registered
  static bool isRegistered<T>() {
    return _instance._services.containsKey(T);
  }

  /// Clear all services (for testing)
  static void clear() {
    _instance._services.clear();
    _instance._initialized = false;
  }
}