import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/consent_request_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/consent_repository.dart';

/// Desktop helper — create consent requests and mirror live status updates.
class ConsentDesktopController extends GetxController {
  ConsentDesktopController({ConsentRepository? repository})
      : _repository = repository ?? Get.find<ConsentRepository>();

  final ConsentRepository _repository;

  /// patientId → latest consent request
  final latestByPatient = <String, ConsentRequestModel>{}.obs;
  final creatingFor = <String>{}.obs;

  final Map<String, StreamSubscription<ConsentRequestModel?>> _subs = {};

  Future<void> requestConsent(PatientModel patient) async {
    if (creatingFor.contains(patient.id)) return;
    creatingFor.add(patient.id);
    try {
      final created = await _repository.createConsentRequest(patient);
      latestByPatient[patient.id] = created;
      _watchPatient(patient.id);
      Get.snackbar(
        'Consent requested',
        'Sent to the consent tablet for ${patient.name}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        'Consent request failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      creatingFor.remove(patient.id);
    }
  }

  void watchPatients(Iterable<PatientModel> patients) {
    for (final p in patients) {
      _watchPatient(p.id);
    }
  }

  void _watchPatient(String patientId) {
    if (patientId.isEmpty || _subs.containsKey(patientId)) return;
    _subs[patientId] = _repository.watchLatestForPatient(patientId).listen(
      (doc) {
        if (doc == null) {
          latestByPatient.remove(patientId);
        } else {
          final previous = latestByPatient[patientId];
          latestByPatient[patientId] = doc;
          if (previous != null &&
              previous.status != doc.status &&
              (doc.isApproved || doc.isDeclined)) {
            Get.snackbar(
              doc.isApproved ? 'Consent approved' : 'Consent declined',
              '${doc.patientName} · ${doc.status}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor:
                  doc.isApproved ? AppColors.successBg : AppColors.warningBg,
              colorText:
                  doc.isApproved ? AppColors.success : AppColors.warning,
              margin: const EdgeInsets.all(12),
            );
          }
        }
        latestByPatient.refresh();
      },
      onError: (_) {},
    );
  }

  ConsentRequestModel? statusFor(String patientId) =>
      latestByPatient[patientId];

  bool isCreating(String patientId) => creatingFor.contains(patientId);

  @override
  void onClose() {
    for (final sub in _subs.values) {
      sub.cancel();
    }
    _subs.clear();
    super.onClose();
  }
}
