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
                            Center(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                    letterSpacing: -0.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'A',
                                      style: TextStyle(color: AppColors.brand600),
                                    ),
                                    TextSpan(text: 'Genomics'),
                                    TextSpan(
                                      text: ' API',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.18 * 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'CLAIM CHECKER',
                                style: TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 11,
                                  letterSpacing: 0.22 * 11,
                                  color: AppColors.brand600,
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
                              height: 1.6,
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
        color: AppColors.night,
      ),
      child: Stack(
        children: [
          // Lavender glow at top
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.15,
                  colors: [
                    AppColors.brand400.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          // 44px lavender grid at ~6% opacity (brand night surface)
          Positioned.fill(
            child: CustomPaint(painter: _NightGridPainter()),
          ),
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand300.withValues(alpha: 0.12),
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
                color: AppColors.brand600.withValues(alpha: 0.14),
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
                      child: _DarkWordmark(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'GENOMIC INFRASTRUCTURE FOR UAE HEALTHCARE',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    letterSpacing: 0.22 * 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand300,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Same data. Safer patient. Cleaner claim.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
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
                    color: AppColors.brand200,
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
                  'Edge v3.0 · PDPL Data Residency',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    color: Color(0x66CECBF6),
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

class _DarkWordmark extends StatelessWidget {
  const _DarkWordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(
            text: 'A',
            style: TextStyle(color: AppColors.brand300),
          ),
          TextSpan(text: 'Genomics'),
          TextSpan(
            text: ' API',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.18 * 11,
              color: Color(0x99FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _NightGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brand300.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.brand300.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        border: Border.all(color: AppColors.brand300.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.brand200,
        ),
      ),
    );
  }
}
