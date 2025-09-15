// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgUZSzUAkxOz1bHElUcggDyQesIw05jT8',
    appId: '1:299988682677:web:f852681d6e4fedf89f3bfc',
    messagingSenderId: '299988682677',
    projectId: 'api52025',
    authDomain: 'api52025.firebaseapp.com',
    storageBucket: 'api52025.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgUZSzUAkxOz1bHElUcggDyQesIw05jT8',
    appId: '1:299988682677:android:f852681d6e4fedf89f3bfc',
    messagingSenderId: '299988682677',
    projectId: 'api52025',
    authDomain: 'api52025.firebaseapp.com',
    storageBucket: 'api52025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgUZSzUAkxOz1bHElUcggDyQesIw05jT8',
    appId: '1:299988682677:ios:f852681d6e4fedf89f3bfc',
    messagingSenderId: '299988682677',
    projectId: 'api52025',
    authDomain: 'api52025.firebaseapp.com',
    storageBucket: 'api52025.firebasestorage.app',
    iosBundleId: 'com.example.api2025',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgUZSzUAkxOz1bHElUcggDyQesIw05jT8',
    appId: '1:299988682677:ios:f852681d6e4fedf89f3bfc',
    messagingSenderId: '299988682677',
    projectId: 'api52025',
    authDomain: 'api52025.firebaseapp.com',
    storageBucket: 'api52025.firebasestorage.app',
    iosBundleId: 'com.example.api2025',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgUZSzUAkxOz1bHElUcggDyQesIw05jT8',
    appId: '1:299988682677:web:f852681d6e4fedf89f3bfc',
    messagingSenderId: '299988682677',
    projectId: 'api52025',
    authDomain: 'api52025.firebaseapp.com',
    storageBucket: 'api52025.firebasestorage.app',
  );
}