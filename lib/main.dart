import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const AGenomicsApp());
}

class AGenomicsApp extends StatelessWidget {
  const AGenomicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute =
        StorageService.isLoggedIn ? AppRoutes.patientList : AppRoutes.login;

    return GetMaterialApp(
      title: 'AGenomics Claim Checker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }
}
