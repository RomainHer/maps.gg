// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAOiK5Sy4dwU3vtB3lVyY2L54-oDY4d-QQ',
    appId: '1:448870242873:web:950a451d09bd9390c40be8',
    messagingSenderId: '448870242873',
    projectId: 'mapsgg-37de8',
    authDomain: 'mapsgg-37de8.firebaseapp.com',
    storageBucket: 'mapsgg-37de8.firebasestorage.app',
    measurementId: 'G-B8FVLQMWBS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBM_nAU_8rUfP38hKFgxpWcLpaSBL99mOE',
    appId: '1:448870242873:android:03e73da23cc68beec40be8',
    messagingSenderId: '448870242873',
    projectId: 'mapsgg-37de8',
    storageBucket: 'mapsgg-37de8.firebasestorage.app',
  );
}
