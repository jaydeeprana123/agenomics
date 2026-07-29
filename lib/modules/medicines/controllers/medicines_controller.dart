import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/repositories/medicine_repository.dart';
import '../views/medicine_form_dialog.dart';

class MedicinesController extends GetxController {
  MedicinesController({MedicineRepository? medicineRepository})
      : _repository = medicineRepository ?? Get.find<MedicineRepository>();

  final MedicineRepository _repository;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final medicines = <MedicineModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  Timer? _debounce;
  int _loadToken = 0;

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  String formatCreatedAt(DateTime? value) {
    if (value == null) return '—';
    return _dateFormat.format(value.toLocal());
  }

  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  Future<void> loadMedicines({bool refresh = false}) async {
    if (isClosed) return;

    final token = ++_loadToken;

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final list = await _repository.searchMedicines(
        search: searchQuery.value,
        skip: 0,
        limit: 100,
      );
      if (isClosed || token != _loadToken) return;
      medicines.assignAll(list);
    } on ApiException catch (e) {
      if (isClosed || token != _loadToken) return;
      errorMessage.value = e.message;
      Get.snackbar(
        'Unable to load medicines',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      if (isClosed || token != _loadToken) return;
      errorMessage.value = 'Unexpected error while loading medicines.';
      Get.snackbar(
        'Unable to load medicines',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed && token == _loadToken) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadMedicines();
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadMedicines();
  }

  Future<void> openCreateDialog() async {
    final created = await Get.dialog<bool>(
      MedicineFormDialog(
        onSubmit: (name, requiresOncologyCheck) => createMedicine(
          name: name,
          requiresOncologyCheck: requiresOncologyCheck,
        ),
      ),
      barrierDismissible: false,
    );
    if (created == true) {
      await loadMedicines(refresh: true);
    }
  }

  Future<void> openEditDialog(MedicineModel medicine) async {
    final updated = await Get.dialog<bool>(
      MedicineFormDialog(
        medicine: medicine,
        onSubmit: (name, requiresOncologyCheck) => updateMedicine(
          medicine: medicine,
          name: name,
          requiresOncologyCheck: requiresOncologyCheck,
        ),
      ),
      barrierDismissible: false,
    );
    if (updated == true) {
      await loadMedicines(refresh: true);
    }
  }

  Future<bool> createMedicine({
    required String name,
    required bool requiresOncologyCheck,
  }) async {
    isSaving.value = true;
    try {
      await _repository.createMedicine(
        MedicineModel(
          id: '',
          name: name,
          requiresOncologyCheck: requiresOncologyCheck,
        ),
      );
      Get.snackbar(
        'Medicine created',
        '"$name" has been added to the formulary.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Create failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Create failed',
        'Unexpected error while creating medicine.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateMedicine({
    required MedicineModel medicine,
    required String name,
    required bool requiresOncologyCheck,
  }) async {
    isSaving.value = true;
    try {
      await _repository.updateMedicine(
        medicine.copyWith(
          name: name,
          requiresOncologyCheck: requiresOncologyCheck,
        ),
      );
      Get.snackbar(
        'Medicine updated',
        '"$name" has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Update failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Update failed',
        'Unexpected error while updating medicine.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> confirmDelete(MedicineModel medicine) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete medicine',
          style: TextStyle(
            fontFamily: 'Mulish',
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Delete "${medicine.name}"? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Mulish', fontSize: 13),
        ),
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
      await _repository.deleteMedicine(medicine.id);
      Get.snackbar(
        'Deleted',
        '"${medicine.name}" has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
      await loadMedicines(refresh: true);
    } on ApiException catch (e) {
      Get.snackbar(
        'Delete failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      Get.snackbar(
        'Delete failed',
        'Unexpected error while deleting medicine.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
