import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo_mark.dart';
import '../../../data/models/consent_request_model.dart';
import '../controllers/consent_inbox_controller.dart';

/// Mobile home — live inbox of pending consent requests from desktop.
class ConsentInboxView extends GetView<ConsentInboxController> {
  const ConsentInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  const AppLogoMark(size: 36),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AGenomics Consent',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkInk,
                          ),
                        ),
                        Text(
                          'Listening for desktop consent requests',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkText3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brand400.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.brand400.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.brand400),
                        SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brand400,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.pending.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.brand400),
                  );
                }

                if (controller.error.value.isNotEmpty &&
                    controller.pending.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          color: AppColors.darkText2,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.pending.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.how_to_reg_outlined,
                            size: 48,
                            color: AppColors.darkText4,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pending consent requests',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkInk,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'When a clinician taps Consent on the patient list, it will appear here instantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 13,
                              color: AppColors.darkText3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: controller.pending.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = controller.pending[index];
                    return _ConsentRequestTile(
                      request: item,
                      onTap: () => controller.openRequest(item),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRequestTile extends StatelessWidget {
  final ConsentRequestModel request;
  final VoidCallback onTap;

  const _ConsentRequestTile({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = request.createdAt != null
        ? DateFormat('dd MMM yyyy · HH:mm').format(request.createdAt!)
        : 'Just now';

    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brand400.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  request.patientName.isNotEmpty
                      ? request.patientName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.brand400,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientName,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.patientUhid} · ${request.hospitalName}',
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: AppColors.darkText3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 11,
                        color: AppColors.darkText4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.darkText3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
