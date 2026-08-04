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
  await AppFirebaseBootstrap.ensureSignedIn();

  final consentRepo = ConsentRepository();
  Get.put<ConsentRepository>(consentRepo, permanent: true);
  Get.put<FcmService>(FcmService(consentRepo), permanent: true);

  runApp(const ConsentMobileApp());
}

class ConsentMobileApp extends StatelessWidget {
  const ConsentMobileApp({super.key});

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
      initialRoute: AppRoutes.consentInbox,
      getPages: AppPages.pages,
      initialBinding: ConsentInboxBinding(),
      defaultTransition: Transition.cupertino,
    );
  }
}
