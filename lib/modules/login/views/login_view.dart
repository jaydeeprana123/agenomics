import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo_mark.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (isWide) const Expanded(flex: 5, child: _BrandPanel()),
          Expanded(
            flex: isWide ? 4 : 1,
            child: Container(
              color: AppColors.background,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isWide) ...[
                            const Center(
                              child: AppLogoMark(size: 40),
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Text(
                                'AGenomics',
                                style: TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                'CLINICAL INTELLIGENCE',
                                style: TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 10,
                                  letterSpacing: 0.16 * 10,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          const Text(
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your credentials to access the clinical platform.',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 13,
                              height: 1.55,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          AppTextField(
                            controller: controller.usernameController,
                            label: 'Username',
                            hint: 'Enter username',
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                            validator: (v) => Validators.required(v, 'Username'),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => AppTextField(
                              controller: controller.passwordController,
                              label: 'Password',
                              hint: 'Enter password',
                              obscureText: !controller.isPasswordVisible.value,
                              textInputAction: TextInputAction.done,
                              onSubmitted: controller.login,
                              prefixIcon: const Icon(Icons.lock_outline, size: 18),
                              suffixIcon: IconButton(
                                onPressed: controller.togglePassword,
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                ),
                              ),
                              validator: (v) => Validators.required(v, 'Password'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => AppButton(
                              label: 'Sign in',
                              expanded: true,
                              height: 44,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(AppColors.radius),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'API credentials',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Username: admin@dch.com  ·  Password: hadmin123',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.night,
      ),
      child: Stack(
        children: [
          // Teal glow (reference --glow1)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.7, -0.85),
                  radius: 1.1,
                  colors: [
                    AppColors.brand400.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.62],
                ),
              ),
            ),
          ),
          // Purple glow (reference --glow2)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, 1.05),
                  radius: 0.9,
                  colors: [
                    AppColors.purple.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.6],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand400.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.purple.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppLogoMark(size: 36, onDark: true),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AGenomics',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkInk,
                              letterSpacing: -0.3,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'CLINICAL INTELLIGENCE',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 10,
                              letterSpacing: 0.16 * 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Same data. Safer patient. Cleaner claim.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkInk,
                    letterSpacing: -0.8,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Score claims, upload genomics files & reports, and prepare prior-auth evidence — from a single responsive workspace.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.darkText2,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Chip(label: 'FHIR R4'),
                    _Chip(label: 'CDS Hooks'),
                    _Chip(label: 'VCF / PDF'),
                  ],
                ),
                const Spacer(),
                const Text(
                  'POC v7.3 · Clinical Intelligence Platform',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    color: AppColors.darkText4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.brand400.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
        border: Border.all(color: AppColors.brand400.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.brand300,
        ),
      ),
    );
  }
}
