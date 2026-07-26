import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePassword() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;
      await _authRepository.login(
        username: usernameController.text,
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.patientList);
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
