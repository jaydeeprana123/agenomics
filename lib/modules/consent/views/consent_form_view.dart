import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/consent_request_model.dart';
import '../controllers/consent_form_controller.dart';

/// Genomic Processing Consent screen — light bilingual layout.
class ConsentFormView extends GetView<ConsentFormController> {
  const ConsentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final req = controller.request.value;
        if (req == null) {
          return const Center(
            child: Text(
              'Consent request not found',
              style: TextStyle(
                fontFamily: 'Mulish',
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final locked = !req.isPending || controller.isSubmitting.value;

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(request: req),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppColors.radius),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.shadowCard,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _PurposeSectionHeader(),
                            const SizedBox(height: 4),
                            Obx(() {
                              final purposes = controller.purposes.value;
                              return Column(
                                children: [
                                  for (final item in ConsentPurposeItem.all)
                                    _PurposeRow(
                                      item: item,
                                      value: _purposeValue(purposes, item.key),
                                      enabled: !locked && !item.required,
                                      onChanged: (v) =>
                                          controller.setValue(item.key, v),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SignatureSection(controller: controller, locked: locked),
                    ],
                  ),
                ),
              ),
              _Footer(controller: controller, locked: locked),
            ],
          ),
        );
      }),
    );
  }
}

bool _purposeValue(ConsentPurposes purposes, String key) {
  switch (key) {
    case 'identityVerification':
      return purposes.identityVerification;
    case 'hieRecordRetrieval':
      return purposes.hieRecordRetrieval;
    case 'pharmacogenomicProcessing':
      return purposes.pharmacogenomicProcessing;
    case 'germlineInterpretation':
      return purposes.germlineInterpretation;
    case 'claimEvidenceAttachment':
      return purposes.claimEvidenceAttachment;
    case 'secondaryResearchUse':
      return purposes.secondaryResearchUse;
    case 'familyCascadeDisclosure':
      return purposes.familyCascadeDisclosure;
    default:
      return false;
  }
}

class _Header extends StatelessWidget {
  final ConsentRequestModel request;

  const _Header({required this.request});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genomic Processing Consent',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${request.hospitalName} · ${request.hospitalRef}',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'الموافقة على المعالجة الجينومية',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${request.patientName} · ${request.patientRef}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurposeSectionHeader extends StatelessWidget {
  const _PurposeSectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'PURPOSE · TOGGLE EACH SEPARATELY',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Text(
          'الغرض',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PurposeRow extends StatelessWidget {
  final ConsentPurposeItem item;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PurposeRow({
    required this.item,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ConsentSwitch(
            value: value,
            enabled: enabled,
            onChanged: onChanged,
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titleEn,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.descriptionEn,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              item.titleAr,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentSwitch extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ConsentSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? AppColors.primary : AppColors.borderStrong,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignatureSection extends StatelessWidget {
  final ConsentFormController controller;
  final bool locked;

  const _SignatureSection({
    required this.controller,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 640;
        final patient = _SignaturePad(
          label: 'PATIENT SIGNATURE · توقيع المريض',
          controller: controller.patientSignature,
          hint: controller.request.value?.patientName.split(' ').first ?? '',
          locked: locked,
          onClear: () => controller.patientSignature.clear(),
        );
        final clinician = Obx(() {
          final name = controller.clinicianName.value;
          return _SignaturePad(
            label: 'CLINICIAN COUNTER-SIGNATURE',
            controller: controller.clinicianSignature,
            hint: name.isEmpty
                ? 'Dr. — ordering oncologist · badge tap'
                : name,
            locked: locked,
            onClear: () => controller.clinicianSignature.clear(),
            onTapHint: locked ? null : controller.onClinicianBadgeTap,
          );
        });

        if (sideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: patient),
              const SizedBox(width: 16),
              Expanded(child: clinician),
            ],
          );
        }
        return Column(
          children: [
            patient,
            const SizedBox(height: 12),
            clinician,
          ],
        );
      },
    );
  }
}

class _SignaturePad extends StatelessWidget {
  final String label;
  final SignatureController controller;
  final String hint;
  final bool locked;
  final VoidCallback onClear;
  final VoidCallback? onTapHint;

  const _SignaturePad({
    required this.label,
    required this.controller,
    required this.hint,
    required this.locked,
    required this.onClear,
    this.onTapHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            if (!locked)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            boxShadow: AppColors.shadowCard,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radius - 1),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _DashedBorderPainter(
                    color: AppColors.borderStrong,
                    radius: AppColors.radius - 1,
                  ),
                  child: const SizedBox.expand(),
                ),
                if (!locked)
                  Signature(
                    controller: controller,
                    backgroundColor: Colors.transparent,
                  ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  right: 16,
                  child: GestureDetector(
                    onTap: onTapHint,
                    child: Text(
                      hint,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _Footer extends StatelessWidget {
  final ConsentFormController controller;
  final bool locked;

  const _Footer({required this.controller, required this.locked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: locked ? null : controller.accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isSubmitting.value) {
                        return const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        );
                      }
                      return const Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: locked ? null : controller.decline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.borderStrong),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Refusing any purpose does not affect treatment',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'الرفض لا يؤثر على علاجك',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
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
