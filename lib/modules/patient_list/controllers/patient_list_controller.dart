import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../shell/controllers/selected_patient_controller.dart';

class PatientListController extends GetxController {
  final PatientRepository _repository = Get.find<PatientRepository>();
  final SelectedPatientController selectedPatient =
      Get.find<SelectedPatientController>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final patients = <PatientModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;
  final perPage = 10;

  /// Filters: All / Male / Female / Other
  final genderFilter = 'All'.obs;

  /// Filters: All / Active / Inactive
  final statusFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  List<PatientModel> get filteredPatients {
    var list = patients.toList();
    if (genderFilter.value != 'All') {
      list = list
          .where((p) =>
              p.gender.toLowerCase() == genderFilter.value.toLowerCase())
          .toList();
    }
    if (statusFilter.value == 'Active') {
      list = list.where((p) => p.isActive).toList();
    } else if (statusFilter.value == 'Inactive') {
      list = list.where((p) => !p.isActive).toList();
    }
    return list;
  }

  Future<void> loadPatients({bool refresh = false}) async {
    if (isClosed) return;

    if (refresh) {
      isRefreshing.value = true;
      currentPage.value = 1;
    } else {
      isLoading.value = true;
    }

    try {
      final result = await _repository.getPatients(
        search: searchQuery.value,
        page: currentPage.value,
        perPage: perPage,
      );
      if (isClosed) return;
      patients.assignAll(result.data);
      lastPage.value = result.lastPage;
      total.value = result.total;
    } catch (e) {
      if (isClosed) return;
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
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

  void onSearchChanged(String value) {
    searchQuery.value = value;
    currentPage.value = 1;
    loadPatients();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadPatients();
  }

  void setGenderFilter(String value) => genderFilter.value = value;

  void setStatusFilter(String value) => statusFilter.value = value;

  void nextPage() {
    if (currentPage.value < lastPage.value) {
      currentPage.value++;
      loadPatients();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadPatients();
    }
  }

  void goToAddPatient() {
    Get.toNamed(AppRoutes.patientRegistration)?.then((_) {
      if (!isClosed) loadPatients(refresh: true);
    });
  }

  Future<void> selectPatient(PatientModel patient) async {
    await selectedPatient.select(patient);
    Get.snackbar(
      'Patient selected',
      '${patient.name} is now active across all screens.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.success,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
    );
  }

  /// Row/card tap: select patient and open Encounters for that patient.
  Future<void> openPatientEncounters(PatientModel patient) async {
    await selectedPatient.select(patient);
    if (Get.currentRoute == AppRoutes.encounters) {
      // Already on encounters — force a reload via re-navigation.
      Get.offNamed(AppRoutes.encounters);
      return;
    }
    Get.toNamed(AppRoutes.encounters);
  }

  Future<void> viewPatient(PatientModel patient) async {
    await selectPatient(patient);

    PatientModel details = patient;
    try {
      final fetched = await _repository.getPatientByUhid(patient.uhid);
      if (fetched != null) {
        details = fetched;
        await selectedPatient.select(details);
      }
    } catch (_) {}

    Get.dialog(
      AlertDialog(
        title: Text(details.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('UHID', details.uhid),
            _row('Mobile', details.mobile),
            _row('Gender', details.gender),
            _row('Age', details.age?.toString() ?? '—'),
            _row('Email', details.email ?? '—'),
            _row('Emirates ID', details.emiratesId ?? '—'),
            _row('Address', details.addressLine ?? '—'),
            _row('City', details.city ?? '—'),
            _row('Source', details.source),
            _row('Status', details.isActive ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editPatient(PatientModel patient) async {
    await selectPatient(patient);
    Get.toNamed(
      AppRoutes.patientEdit,
      arguments: patient,
    )?.then((_) {
      if (!isClosed) loadPatients(refresh: true);
    });
  }

  Future<void> continuePatient(PatientModel patient) async {
    await selectPatient(patient);
    Get.toNamed(
      AppRoutes.uploadDocuments,
      arguments: patient,
    )?.then((_) {
      if (!isClosed) loadPatients(refresh: true);
    });
  }

  Future<void> deletePatient(PatientModel patient) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete patient'),
        content: Text('Delete ${patient.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.deletePatient(patient.uhid);
      if (selectedPatient.isSelected(patient)) {
        await selectedPatient.clear();
      }
      Get.snackbar(
        'Deleted',
        '${patient.name} has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
      await loadPatients(refresh: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
