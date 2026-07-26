import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/patient_repository.dart';

class PatientRegistrationController extends GetxController {
  final PatientRepository _repository = Get.find<PatientRepository>();

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressLineController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final emiratesIdController = TextEditingController();
  final sourceController = TextEditingController(text: 'manual');

  final gender = RxnString();
  final dateOfBirth = Rxn<DateTime>();
  final isLoading = false.obs;
  final isEditMode = false.obs;

  PatientModel? editingPatient;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PatientModel) {
      editingPatient = args;
      isEditMode.value = true;
      _fillForm(args);
    }
  }

  void _fillForm(PatientModel p) {
    firstNameController.text = p.firstName;
    lastNameController.text = p.lastName;
    mobileController.text = p.mobile;
    emailController.text = p.email ?? '';
    addressLineController.text = p.addressLine ?? '';
    cityController.text = p.city ?? '';
    stateController.text = p.state ?? '';
    pincodeController.text = p.pincode ?? '';
    emiratesIdController.text = p.emiratesId ?? '';
    sourceController.text = p.source;
    gender.value = p.gender.isEmpty ? null : p.gender;
    dateOfBirth.value = p.dob;
    _syncAgeFromDob();
  }

  static int? calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  void _syncAgeFromDob() {
    final age = calculateAge(dateOfBirth.value);
    ageController.text = age?.toString() ?? '';
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth.value ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateOfBirth.value = picked;
      _syncAgeFromDob();
    }
  }

  PatientModel _buildModel() {
    final address = PatientAddress(
      line: addressLineController.text.trim().isEmpty
          ? null
          : addressLineController.text.trim(),
      city: cityController.text.trim().isEmpty
          ? null
          : cityController.text.trim(),
      state: stateController.text.trim().isEmpty
          ? null
          : stateController.text.trim(),
      pincode: pincodeController.text.trim().isEmpty
          ? null
          : pincodeController.text.trim(),
    );

    return PatientModel(
      id: editingPatient?.id ?? '',
      uhid: editingPatient?.uhid ?? '',
      hospitalId: editingPatient?.hospitalId ?? '',
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      dob: dateOfBirth.value,
      gender: gender.value ?? '',
      mobile: mobileController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      address: address.isEmpty ? null : address,
      emiratesId: emiratesIdController.text.trim().isEmpty
          ? null
          : emiratesIdController.text.trim(),
      source: sourceController.text.trim().isEmpty
          ? 'manual'
          : sourceController.text.trim(),
      isActive: editingPatient?.isActive ?? true,
    );
  }

  Future<PatientModel?> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return null;

    if (gender.value == null || gender.value!.isEmpty) {
      _showValidation('Please select gender');
      return null;
    }
    if (dateOfBirth.value == null) {
      _showValidation('Please select date of birth');
      return null;
    }

    isLoading.value = true;
    try {
      final model = _buildModel();
      if (isEditMode.value) {
        return await _repository.updatePatient(model);
      }
      return await _repository.createPatient(model);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        duration: const Duration(seconds: 4),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void _showValidation(String message) {
    Get.snackbar(
      'Validation',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warningBg,
      colorText: AppColors.warning,
    );
  }

  Future<void> saveAndReturn() async {
    final saved = await _save();
    if (saved == null) return;
    Get.snackbar(
      'Saved',
      'Patient ${saved.name} saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.success,
    );
    // Prefer popping back so PatientListController is not disposed mid-rebuild.
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(result: saved);
    } else {
      Get.offAllNamed(AppRoutes.patientList);
    }
  }

  Future<void> saveAndContinue() async {
    final saved = await _save();
    if (saved == null) return;
    Get.offNamed(
      AppRoutes.uploadDocuments,
      arguments: saved,
    );
  }

  String get dobDisplay {
    final dob = dateOfBirth.value;
    if (dob == null) return '';
    return DateFormat('dd MMM yyyy').format(dob);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressLineController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    emiratesIdController.dispose();
    sourceController.dispose();
    super.onClose();
  }
}
