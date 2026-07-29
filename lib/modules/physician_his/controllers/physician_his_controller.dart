import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/engine_check_model.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../../shell/controllers/selected_patient_controller.dart';

class PhysicianHisController extends GetxController {
  PhysicianHisController({MedicineRepository? medicineRepository})
      : _medicines = medicineRepository ?? Get.find<MedicineRepository>();

  final MedicineRepository _medicines;
  final SelectedPatientController selectedPatient =
      Get.find<SelectedPatientController>();

  final searchController = TextEditingController();
  final searchFocus = FocusNode();

  final searchQuery = ''.obs;
  final searchResults = <MedicineModel>[].obs;
  final selectedMedicines = <MedicineModel>[].obs;
  final isSearching = false.obs;
  final searchError = RxnString();
  final showResults = false.obs;

  final isRunning = false.obs;
  final engineError = RxnString();
  final engineResult = Rxn<EngineCheckResponse>();
  final hasRun = false.obs;

  Timer? _debounce;
  int _searchToken = 0;
  int _engineToken = 0;

  PatientModel? get patient => selectedPatient.selected.value;

  @override
  void onInit() {
    super.onInit();
    if (patient == null || (patient?.id.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Select a patient',
          'Choose a patient from the Patient List before opening Physician / HIS.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.text,
        );
        Get.offNamed(AppRoutes.patientList);
      });
      return;
    }

    searchController.addListener(_onSearchChanged);
    searchFocus.addListener(() {
      if (searchFocus.hasFocus && searchResults.isNotEmpty) {
        showResults.value = true;
      }
    });
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    searchQuery.value = query;
    _debounce?.cancel();

    if (query.length < 2) {
      searchResults.clear();
      searchError.value = null;
      isSearching.value = false;
      showResults.value = false;
      return;
    }

    isSearching.value = true;
    showResults.value = true;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchMedicines(query);
    });
  }

  Future<void> _searchMedicines(String query) async {
    final token = ++_searchToken;
    isSearching.value = true;
    searchError.value = null;

    try {
      final results = await _medicines.searchMedicines(search: query);
      if (token != _searchToken) return;

      final selectedIds = selectedMedicines.map((m) => m.id).toSet();
      searchResults.assignAll(
        results.where((m) => !selectedIds.contains(m.id)).toList(),
      );
      showResults.value = true;
    } on ApiException catch (e) {
      if (token != _searchToken) return;
      searchError.value = e.message;
      searchResults.clear();
    } catch (_) {
      if (token != _searchToken) return;
      searchError.value = 'Unable to search medicines. Please try again.';
      searchResults.clear();
    } finally {
      if (token == _searchToken) {
        isSearching.value = false;
      }
    }
  }

  void selectMedicine(MedicineModel medicine) {
    if (selectedMedicines.any((m) => m.id == medicine.id)) return;
    selectedMedicines.add(medicine);
    searchResults.removeWhere((m) => m.id == medicine.id);
    searchController.clear();
    searchQuery.value = '';
    showResults.value = false;
    searchFocus.unfocus();
    engineError.value = null;
    // Auto-run engine check with the updated prescribed list.
    runEngineCheck();
  }

  void removeMedicine(MedicineModel medicine) {
    selectedMedicines.removeWhere((m) => m.id == medicine.id);
    engineError.value = null;
  }

  void clearResultsPanel() {
    showResults.value = false;
  }

  String medicineNameFor(String? medicineId) {
    if (medicineId == null || medicineId.isEmpty) return '';
    final match = selectedMedicines.firstWhereOrNull((m) => m.id == medicineId);
    return match?.name ?? '';
  }

  Future<void> runEngineCheck() async {
    final current = patient;
    if (current == null || current.id.isEmpty) {
      engineError.value = 'No patient selected. Return to Patient List.';
      return;
    }

    if (selectedMedicines.isEmpty) {
      engineError.value = null;
      return;
    }

    final token = ++_engineToken;
    final medicineIds = selectedMedicines.map((m) => m.id).toList();

    isRunning.value = true;
    engineError.value = null;

    try {
      final result = await _medicines.runEngineCheck(
        patientId: current.id,
        medicineIds: medicineIds,
      );
      if (token != _engineToken) return;
      engineResult.value = result;
      hasRun.value = true;
    } on ApiException catch (e) {
      if (token != _engineToken) return;
      if (e.statusCode == 401) {
        engineError.value = 'Session expired. Please sign in again.';
      } else {
        engineError.value = e.message;
      }
      Get.snackbar(
        'Engine check failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.text,
      );
    } catch (_) {
      if (token != _engineToken) return;
      engineError.value = 'Unexpected error while running engine check.';
      Get.snackbar(
        'Engine check failed',
        engineError.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.text,
      );
    } finally {
      if (token == _engineToken) {
        isRunning.value = false;
      }
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}
