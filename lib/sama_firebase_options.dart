import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SamaFirebaseOptions {
  static Future<FirebaseOptions> get currentPlatform async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Error loading .env file: $e');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'SamaFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_ANDROID'] ?? '',
    appId: dotenv.env['APP_ID_ANDROID'] ?? '',
    messagingSenderId: dotenv.env['MESSAGING_SENDER_ID_ANDROID'] ?? '',
    projectId: dotenv.env['PROJECT_ID_ANDROID'] ?? '',
    storageBucket: dotenv.env['STORAGE_BUCKET_ANDROID'] ?? '',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_IOS'] ?? '',
    appId: dotenv.env['APP_ID_IOS'] ?? '',
    messagingSenderId: dotenv.env['MESSAGING_SENDER_ID_IOS'] ?? '',
    projectId: dotenv.env['PROJECT_ID_IOS'] ?? '',
    storageBucket: dotenv.env['STORAGE_BUCKET_IOS'] ?? '',
    iosBundleId: dotenv.env['IOS_BUNDLE_ID_IOS'] ?? '',
  );
}
