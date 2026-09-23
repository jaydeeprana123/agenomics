import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/consent_request_model.dart';
import '../../../data/repositories/consent_repository.dart';

class ConsentFormController extends GetxController {
  ConsentFormController({ConsentRepository? repository})
      : _repository = repository ?? Get.find<ConsentRepository>();

  final ConsentRepository _repository;

  late final SignatureController patientSignature;
  late final SignatureController clinicianSignature;

  final request = Rxn<ConsentRequestModel>();
  final purposes = const ConsentPurposes().obs;
  final clinicianName = ''.obs;
  final isSubmitting = false.obs;
  final isLoading = true.obs;

  StreamSubscription<ConsentRequestModel?>? _sub;

  @override
  void onInit() {
    super.onInit();
    patientSignature = SignatureController(
      penStrokeWidth: 2.4,
      penColor: AppColors.primary,
      exportBackgroundColor: Colors.transparent,
    );
    clinicianSignature = SignatureController(
      penStrokeWidth: 2.4,
      penColor: AppColors.ink,
      exportBackgroundColor: Colors.transparent,
    );

    final args = Get.arguments;
    if (args is ConsentRequestModel) {
      _bindRequest(args);
      _listen(args.id);
    } else if (args is String) {
      _load(args);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _load(String id) async {
    isLoading.value = true;
    try {
      final doc = await _repository.getRequest(id);
      if (doc != null) {
        _bindRequest(doc);
        _listen(id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _bindRequest(ConsentRequestModel doc) {
    request.value = doc;
    purposes.value = doc.purposes;
    clinicianName.value = doc.clinicianName ?? '';
    isLoading.value = false;
  }

  void _listen(String id) {
    _sub?.cancel();
    _sub = _repository.watchRequest(id).listen((doc) {
      if (doc == null) return;
      request.value = doc;
    });
  }

  void setValue(String key, bool value) {
    final p = purposes.value;
    purposes.value = switch (key) {
      'identityVerification' => p.copyWith(identityVerification: value),
      'hieRecordRetrieval' => p.copyWith(hieRecordRetrieval: value),
      'pharmacogenomicProcessing' =>
        p.copyWith(pharmacogenomicProcessing: value),
      'germlineInterpretation' => p.copyWith(germlineInterpretation: value),
      'claimEvidenceAttachment' => p.copyWith(claimEvidenceAttachment: value),
      'secondaryResearchUse' => p.copyWith(secondaryResearchUse: value),
      'familyCascadeDisclosure' => p.copyWith(familyCascadeDisclosure: value),
      _ => p,
    };
  }

  void onClinicianBadgeTap() {
    if (clinicianName.value.trim().isEmpty) {
      clinicianName.value = 'Dr. — ordering oncologist';
    }
  }

  void _goToConsentList([String? result]) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    if (Get.key.currentState?.canPop() == true) {
      Get.back(result: result);
      return;
    }
    Get.offAllNamed(AppRoutes.consentInbox);
  }

  void _showSuccessAfterNavigation(String message) {
    // Snackbar must show after navigation — Get.snackbar before Get.back
    // is treated as a route and Get.back only dismisses the snackbar.
    Future.microtask(() {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// Accept — signature required for validation only (not uploaded).
  Future<void> accept() async {
    final current = request.value;
    if (current == null || !current.isPending) return;

    if (patientSignature.isEmpty) {
      Get.snackbar(
        'Signature required',
        'Please add your signature before submitting the consent form.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (!purposes.value.identityVerification) {
      Get.snackbar(
        'Required',
        'Identity verification is always required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final finalPurposes =
          purposes.value.copyWith(identityVerification: true);

      await _repository.submitConsent(
        requestId: current.id,
        purposes: finalPurposes,
        clinicianName: clinicianName.value.trim().isEmpty
            ? null
            : clinicianName.value.trim(),
        patientSigned: true,
        clinicianSigned: clinicianSignature.isNotEmpty,
      );

      _goToConsentList(ConsentStatus.approved);
      _showSuccessAfterNavigation('Consent accepted successfully.');
    } catch (e) {
      Get.snackbar(
        'Accept failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  /// Decline — signature not required.
  Future<void> decline() async {
    final current = request.value;
    if (current == null || !current.isPending) return;

    isSubmitting.value = true;
    try {
      await _repository.declineConsent(current.id);
      _goToConsentList(ConsentStatus.declined);
      _showSuccessAfterNavigation('Consent declined successfully.');
    } catch (e) {
      Get.snackbar(
        'Decline failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    patientSignature.dispose();
    clinicianSignature.dispose();
    super.onClose();
  }
}
