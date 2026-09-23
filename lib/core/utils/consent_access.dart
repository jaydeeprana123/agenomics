import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../data/models/consent_request_model.dart';
import '../../modules/consent/controllers/consent_desktop_controller.dart';
import '../../modules/shell/controllers/selected_patient_controller.dart';

/// Routes reachable without approved genomic consent for the selected patient.
abstract class ConsentAccess {
  ConsentAccess._();

  static const String requiredTitle = 'Consent approval required';

  static const String requiredMessage =
      'Genomic processing consent must be approved for the selected patient '
      'before you can access this section. Request consent from the Patient List.';

  static const _allowedRoutes = <String>{
    AppRoutes.login,
    AppRoutes.patientList,
    AppRoutes.encounters,
    AppRoutes.patientRegistration,
    AppRoutes.patientEdit,
    AppRoutes.consentInbox,
    AppRoutes.consentForm,
  };

  static bool routeRequiresConsent(String? route) {
    if (route == null || route.isEmpty) return false;
    return !_allowedRoutes.contains(route);
  }

  static bool hasApprovedConsent(String? patientId) {
    if (patientId == null || patientId.isEmpty) return false;
    if (!Get.isRegistered<ConsentDesktopController>()) return false;
    return Get.find<ConsentDesktopController>().hasApprovedConsent(patientId);
  }

  static ConsentRequestModel? consentFor(String? patientId) {
    if (patientId == null || patientId.isEmpty) return null;
    if (!Get.isRegistered<ConsentDesktopController>()) return null;
    return Get.find<ConsentDesktopController>().statusFor(patientId);
  }

  /// Whether navigation to [route] is allowed for [patientId] (or current selection).
  static bool canAccessRoute(
    String route, {
    String? patientId,
  }) {
    if (!routeRequiresConsent(route)) return true;

    final id = patientId ??
        Get.find<SelectedPatientController>().selected.value?.id ??
        '';
    return hasApprovedConsent(id);
  }

  static void showConsentRequiredMessage() {
    Get.snackbar(
      requiredTitle,
      requiredMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
    );
  }

  /// Returns false when navigation should be blocked.
  static bool guardNavigation(String route, {String? patientId}) {
    if (canAccessRoute(route, patientId: patientId)) return true;
    showConsentRequiredMessage();
    return false;
  }
}
