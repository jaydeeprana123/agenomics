import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/encounter_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/encounter_repository.dart';
import '../../shell/controllers/selected_encounter_controller.dart';
import '../../shell/controllers/selected_patient_controller.dart';
import '../views/encounter_details_dialog.dart';

class EncountersController extends GetxController {
  EncountersController({EncounterRepository? encounterRepository})
      : _repository = encounterRepository ?? Get.find<EncounterRepository>();

  final EncounterRepository _repository;
  final SelectedPatientController selectedPatient =
      Get.find<SelectedPatientController>();
  final SelectedEncounterController selectedEncounter =
      Get.find<SelectedEncounterController>();

  final encounters = <EncounterModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingDetails = false.obs;
  final errorMessage = RxnString();

  PatientModel? get patient => selectedPatient.selected.value;

  @override
  void onInit() {
    super.onInit();
    if (patient == null || (patient?.id.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Select a patient',
          'Choose a patient from the Patient List before opening Encounters.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.text,
        );
        Get.offNamed(AppRoutes.patientList);
      });
      return;
    }

    loadEncounters();
  }

  Future<void> loadEncounters({bool refresh = false}) async {
    if (isClosed) return;

    final current = patient;
    if (current == null || current.id.isEmpty) {
      errorMessage.value = 'No patient selected.';
      return;
    }

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final list = await _repository.getPatientEncounters(current.id);
      if (isClosed) return;
      encounters.assignAll(list);

      // Keep header selection only if it still belongs to this patient list.
      final active = selectedEncounter.selected.value;
      if (active != null &&
          (active.patientId != current.id ||
              !list.any((e) => e.id == active.id))) {
        await selectedEncounter.clearIfNotForPatient(current.id);
        if (active.patientId == current.id &&
            !list.any((e) => e.id == active.id)) {
          await selectedEncounter.clear();
        }
      }
    } on ApiException catch (e) {
      if (isClosed) return;
      errorMessage.value = e.message;
      Get.snackbar(
        'Unable to load encounters',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      if (isClosed) return;
      errorMessage.value = 'Unexpected error while loading encounters.';
      Get.snackbar(
        'Unable to load encounters',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  Future<void> selectEncounter(EncounterModel encounter) async {
    await selectedEncounter.select(encounter);
    Get.snackbar(
      'Visit selected',
      '${encounter.displayLabel} is now active across all screens.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.success,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
    );
  }

  /// Eye / View: fetch GET `/api/v1/encounters/{id}` and show details dialog.
  Future<void> viewEncounter(EncounterModel encounter) async {
    if (isLoadingDetails.value) return;
    if (encounter.id.isEmpty) {
      _showDetailsError(
        title: 'Encounter unavailable',
        message: 'This encounter has no ID and cannot be loaded.',
      );
      return;
    }

    isLoadingDetails.value = true;
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading encounter details…',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final details = await _repository.getEncounterById(encounter.id);
      if (isClosed) return;
      _closeLoadingDialog();

      if (details == null) {
        _showDetailsError(
          title: 'Encounter not found',
          message:
              'No details were returned for visit ${encounter.displayLabel}.',
          onRetry: () => viewEncounter(encounter),
        );
        return;
      }

      Get.dialog(
        EncounterDetailsDialog(details: details),
        barrierDismissible: true,
      );
    } on ApiException catch (e) {
      if (isClosed) return;
      _closeLoadingDialog();
      _showDetailsError(
        title: 'Unable to load details',
        message: e.message,
        onRetry: () => viewEncounter(encounter),
      );
    } catch (_) {
      if (isClosed) return;
      _closeLoadingDialog();
      _showDetailsError(
        title: 'Unable to load details',
        message:
            'Unexpected error while loading encounter details. Check your network and try again.',
        onRetry: () => viewEncounter(encounter),
      );
    } finally {
      if (!isClosed) isLoadingDetails.value = false;
    }
  }

  void _closeLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void _showDetailsError({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
