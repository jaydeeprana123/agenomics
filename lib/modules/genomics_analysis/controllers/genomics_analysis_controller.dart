import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/models/pgx_result_model.dart';
import '../../../data/repositories/pgx_repository.dart';
import '../../shell/controllers/selected_patient_controller.dart';

class GenomicsAnalysisController extends GetxController {
  GenomicsAnalysisController({PgxRepository? pgxRepository})
      : _repository = pgxRepository ?? Get.find<PgxRepository>();

  final PgxRepository _repository;
  final SelectedPatientController selectedPatient =
      Get.find<SelectedPatientController>();

  final results = <PgxResultModel>[].obs;
  final panelRows = <PgxPanelRow>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  PatientModel? get patient => selectedPatient.selected.value;

  String get sourceLabel {
    final source = patient?.source.trim() ?? '';
    if (source.isEmpty) return 'Malaffi HIE';
    switch (source.toLowerCase()) {
      case 'hl7':
        return 'Malaffi HIE';
      case 'fhir':
        return 'FHIR R4 · HIE';
      case 'vcf':
        return '3rd-party VCF';
      case 'manual':
        return 'Manual entry';
      default:
        return source;
    }
  }

  String get pharmCatRunLabel {
    final source = (patient?.source ?? '').toLowerCase();
    if (source.contains('vcf')) return 'Yes — on-edge';
    return 'No — pre-interpreted';
  }

  @override
  void onInit() {
    super.onInit();
    if (patient == null || (patient?.id.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Select a patient',
          'Choose a patient from the Patient List before opening Genomic Analysis.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.text,
        );
        Get.offNamed(AppRoutes.patientList);
      });
      return;
    }

    loadResults();
  }

  Future<void> loadResults({bool refresh = false}) async {
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
      final list = await _repository.getPgxResults(current.id);
      if (isClosed) return;
      results.assignAll(list);
      panelRows.assignAll(PgxPanelRow.fromResults(list));
    } on ApiException catch (e) {
      if (isClosed) return;
      if (e.statusCode == 401) {
        errorMessage.value = 'Session expired. Please sign in again.';
      } else {
        errorMessage.value = e.message;
      }
      Get.snackbar(
        'Unable to load PGx results',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      if (isClosed) return;
      errorMessage.value = 'Unexpected error while loading PGx results.';
      Get.snackbar(
        'Unable to load PGx results',
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
}
