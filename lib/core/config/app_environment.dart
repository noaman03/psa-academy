import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppEnvironment {
  static const String _envString = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );

  static const String stagingProjectId = String.fromEnvironment(
    'STAGING_PROJECT_ID',
    defaultValue: 'psa-academy-staging',
  );

  static const String productionProjectId = 'psa-academy-65088';

  static Environment get current {
    switch (_envString.toLowerCase()) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'production':
      case 'prod':
      default:
        return Environment.production;
    }
  }

  static bool get isDevelopment => current == Environment.development;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;

  static String get projectId {
    switch (current) {
      case Environment.development:
        return 'demo-psa-academy';
      case Environment.staging:
        return stagingProjectId;
      case Environment.production:
        return productionProjectId;
    }
  }

  static FirebaseOptions get firebaseOptions {
    switch (current) {
      case Environment.development:
        return const FirebaseOptions(
          apiKey: "AIzaFakeDevApiKeyForLocalEmulators123",
          storageBucket: "demo-psa-academy.appspot.com",
          appId: "1:1234567890:web:devdemoapp",
          messagingSenderId: "1234567890",
          projectId: "demo-psa-academy",
        );
      case Environment.staging:
        return const FirebaseOptions(
          apiKey: String.fromEnvironment(
            'STAGING_API_KEY',
            defaultValue: "AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI",
          ),
          storageBucket: "psa-academy-staging.firebasestorage.app",
          appId: "1:441143149918:web:8adf7625396ff49e8cfbcf",
          messagingSenderId: "441143149918",
          projectId: stagingProjectId,
          authDomain: "psa-academy-staging.firebaseapp.com",
        );
      case Environment.production:
        return const FirebaseOptions(
          apiKey: "AIzaSyBpS5SLEllgLbnghtAT6JEH7UMnQ-Tmjz4",
          storageBucket: "psa-academy-65088.firebasestorage.app",
          appId: "1:353959379596:web:9e2db8c46070672e6f71a9",
          messagingSenderId: "353959379596",
          projectId: "psa-academy-65088",
        );
    }
  }

  /// Configures local Firebase emulators for development/testing
  static Future<void> configureEmulatorsIfEnabled({
    String host = 'localhost',
    int authPort = 9099,
    int firestorePort = 8080,
    int storagePort = 9199,
  }) async {
    if (useEmulator || isDevelopment) {
      debugPrint(
        'Connecting to Firebase Emulators at $host (Auth: $authPort, Firestore: $firestorePort, Storage: $storagePort)',
      );
      try {
        await FirebaseAuth.instance.useAuthEmulator(host, authPort);
        FirebaseFirestore.instance.useFirestoreEmulator(host, firestorePort);
        await FirebaseStorage.instance.useStorageEmulator(host, storagePort);
      } catch (e) {
        debugPrint('Emulator connection notice: $e');
      }
    }
  }
}
