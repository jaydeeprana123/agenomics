import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
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
                            Center(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                                  children: [
                                    TextSpan(text: 'A'),
                                    TextSpan(
                                      text: 'Genomics',
                                      style: TextStyle(color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Claim Checker',
                                style: TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your credentials to access the claim checker.',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 13,
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
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Username: admin@dch.com  ·  Password: hadmin123',
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF080E1E),
            Color(0xFF0D1E2A),
            Color(0xFF0A2A22),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
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
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: 'A'),
                      TextSpan(
                        text: 'Genomics',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'CLINICAL API PLATFORM · UAE',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0x66FFFFFF),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Claim Checker',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Score claims, upload genomics files & reports, and prepare prior-auth evidence — from a single responsive workspace.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0x73FFFFFF),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Chip(label: 'Patients'),
                    _Chip(label: 'VCF / PDF Upload'),
                    _Chip(label: 'Laravel-ready'),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Edge v3.0 · PDPL Data Residency',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    color: Color(0x4DFFFFFF),
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
        color: const Color(0x2416A07A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4D16A07A)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
