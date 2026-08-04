// File generated manually from android/app/google-services.json
// for Firebase project agenomics-97b8c.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android; // Reuse Android until iOS app is registered.
      case TargetPlatform.macOS:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnsq76uLba2LS3Df7KLWUpzcP7KVQwuno',
    appId: '1:538424652584:android:3094266adbaf71955bd61d',
    messagingSenderId: '538424652584',
    projectId: 'agenomics-97b8c',
    storageBucket: 'agenomics-97b8c.firebasestorage.app',
  );

  /// Web / Windows reuse the Android client until separate apps are registered
  /// in the Firebase console for this project.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCnsq76uLba2LS3Df7KLWUpzcP7KVQwuno',
    appId: '1:538424652584:android:3094266adbaf71955bd61d',
    messagingSenderId: '538424652584',
    projectId: 'agenomics-97b8c',
    authDomain: 'agenomics-97b8c.firebaseapp.com',
    storageBucket: 'agenomics-97b8c.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCnsq76uLba2LS3Df7KLWUpzcP7KVQwuno',
    appId: '1:538424652584:android:3094266adbaf71955bd61d',
    messagingSenderId: '538424652584',
    projectId: 'agenomics-97b8c',
    authDomain: 'agenomics-97b8c.firebaseapp.com',
    storageBucket: 'agenomics-97b8c.firebasestorage.app',
  );
}
