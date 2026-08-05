import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/services/firebase_service.dart';
import 'core/services/fcm_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'data/repositories/consent_repository.dart';
import 'firebase_options.dart';
import 'modules/consent/bindings/consent_binding.dart';

/// Separate mobile APK entry for consent management only.
///
/// Build:
/// ```
/// flutter build apk --target=lib/main_consent.dart --release
/// ```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final user = await AppFirebaseBootstrap.ensureSignedIn();

  final consentRepo = ConsentRepository();
  Get.put<ConsentRepository>(consentRepo, permanent: true);
  Get.put<FcmService>(FcmService(consentRepo), permanent: true);

  runApp(ConsentMobileApp(authReady: user != null));
}

class ConsentMobileApp extends StatelessWidget {
  final bool authReady;

  const ConsentMobileApp({super.key, required this.authReady});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AGenomics Consent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.night,
        fontFamily: 'Mulish',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brand400,
          surface: AppColors.panel,
        ),
      ),
      home: authReady
          ? null
          : const _FirebaseAuthSetupScreen(),
      initialRoute: authReady ? AppRoutes.consentInbox : null,
      getPages: AppPages.pages,
      initialBinding: authReady ? ConsentInboxBinding() : null,
      defaultTransition: Transition.cupertino,
    );
  }
}

class _FirebaseAuthSetupScreen extends StatelessWidget {
  const _FirebaseAuthSetupScreen();

  @override
  Widget build(BuildContext context) {
    final detail = AppFirebaseBootstrap.lastAuthError ?? 'Unknown error';

    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase Auth not configured',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkInk,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                detail,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  color: AppColors.darkText3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fix in Firebase Console (agenomics-97b8c):',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand400,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Open Authentication\n'
                '2. Get started (if prompted)\n'
                '3. Sign-in method → Anonymous → Enable → Save\n'
                '4. Restart this app',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.darkText2,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = await AppFirebaseBootstrap.ensureSignedIn();
                    if (user != null) {
                      Get.offAllNamed(AppRoutes.consentInbox);
                    } else {
                      Get.snackbar(
                        'Still failing',
                        AppFirebaseBootstrap.lastAuthError ??
                            'Enable Anonymous auth, then retry.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.panel,
                        colorText: AppColors.darkInk,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand400,
                    foregroundColor: AppColors.onTeal,
                  ),
                  child: const Text(
                    'Retry sign-in',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
