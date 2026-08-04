import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Bootstraps Firebase Core + anonymous Auth for consent flows.
class AppFirebaseBootstrap {
  AppFirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await ensureSignedIn();
      _initialized = true;
    } catch (e, st) {
      debugPrint('AppFirebaseBootstrap.init failed: $e\n$st');
      rethrow;
    }
  }

  /// Anonymous auth so Firestore / Storage rules can require authentication
  /// without introducing a separate backend user store for consent tablets.
  static Future<User?> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    final cred = await auth.signInAnonymously();
    return cred.user;
  }
}
