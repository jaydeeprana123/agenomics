import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Bootstraps Firebase Core + anonymous Auth for consent flows.
class AppFirebaseBootstrap {
  AppFirebaseBootstrap._();

  static bool _initialized = false;
  static String? lastAuthError;

  static bool get isInitialized => _initialized;
  static bool get isSignedIn => FirebaseAuth.instance.currentUser != null;

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
  ///
  /// Returns null if Anonymous sign-in is not enabled in the Firebase Console
  /// (`CONFIGURATION_NOT_FOUND` / provider disabled).
  static Future<User?> ensureSignedIn() async {
    lastAuthError = null;
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    try {
      final cred = await auth.signInAnonymously();
      return cred.user;
    } on FirebaseAuthException catch (e) {
      lastAuthError = e.message ?? e.code;
      debugPrint(
        'Anonymous sign-in failed (${e.code}): ${e.message}\n'
        'Enable Authentication → Sign-in method → Anonymous in Firebase Console '
        'for project agenomics-97b8c.',
      );
      return null;
    } catch (e) {
      lastAuthError = e.toString();
      debugPrint('Anonymous sign-in failed: $e');
      return null;
    }
  }
}
