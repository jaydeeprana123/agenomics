import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/models/consent_request_model.dart';
import '../../modules/consent/controllers/consent_desktop_controller.dart';
import '../../modules/shell/controllers/selected_patient_controller.dart';
import '../utils/consent_access.dart';
import 'empty_state.dart';

/// Blocks content until the selected patient has approved genomic consent.
class ConsentRequiredGate extends StatelessWidget {
  final Widget child;

  const ConsentRequiredGate({super.key, required this.child});

  void _openPatientList() {
    if (Get.currentRoute == AppRoutes.patientList) return;
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.patientList || route.isFirst,
    );
    if (Get.currentRoute != AppRoutes.patientList) {
      Get.offAllNamed(AppRoutes.patientList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPatient = Get.find<SelectedPatientController>();
    final consent = Get.find<ConsentDesktopController>();

    return Obx(() {
      final patient = selectedPatient.selected.value;
      final patientId = patient?.id ?? '';

      // Depend on consent map updates for this patient.
      consent.latestByPatient;
      final approved = ConsentAccess.hasApprovedConsent(patientId);

      if (patient == null || patientId.isEmpty) {
        return EmptyState(
          icon: Icons.person_search_outlined,
          title: 'Select a patient',
          subtitle:
              'Choose a patient from the Patient List before opening this section.',
          actionLabel: 'Go to Patient List',
          onAction: _openPatientList,
        );
      }

      if (!approved) {
        final status = ConsentAccess.consentFor(patientId)?.status;
        final statusHint = switch (status) {
          ConsentStatus.pending => ' Consent is pending on the consent tablet.',
          ConsentStatus.declined => ' Consent was declined — request again from the Patient List.',
          _ => ' Request consent using the Consent button on the Patient List.',
        };

        return EmptyState(
          icon: Icons.how_to_reg_outlined,
          title: ConsentAccess.requiredTitle,
          subtitle: '${ConsentAccess.requiredMessage}$statusHint',
          actionLabel: 'Go to Patient List',
          onAction: _openPatientList,
        );
      }

      return child;
    });
  }
}
