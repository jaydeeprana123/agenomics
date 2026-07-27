import 'package:get/get.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/patient_model.dart';
import 'selected_encounter_controller.dart';

/// Global selected patient — available on every screen via GetX + GetStorage.
class SelectedPatientController extends GetxController {
  final selected = Rxn<PatientModel>();

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final data = StorageService.read(StorageKeys.selectedPatient);
    if (data is Map) {
      try {
        final patient =
            PatientModel.fromJson(Map<String, dynamic>.from(data));
        selected.value = patient;
        // Ensure individual keys stay in sync after app restart.
        _writeIndividualKeys(patient);
      } catch (_) {
        selected.value = null;
      }
    }
  }

  Future<void> select(PatientModel patient) async {
    final previousId = selected.value?.id;
    selected.value = patient;
    await StorageService.write(
      StorageKeys.selectedPatient,
      patient.toJson(),
    );
    await _writeIndividualKeys(patient);

    // Switching patients invalidates the previous visit selection.
    if (previousId != null && previousId != patient.id) {
      await _clearEncounter();
    } else if (Get.isRegistered<SelectedEncounterController>()) {
      await Get.find<SelectedEncounterController>()
          .clearIfNotForPatient(patient.id);
    }
  }

  Future<void> _writeIndividualKeys(PatientModel patient) async {
    await StorageService.write(StorageKeys.selectedPatientId, patient.id);
    await StorageService.write(StorageKeys.selectedPatientName, patient.name);
    await StorageService.write(StorageKeys.selectedPatientMrn, patient.uhid);
    await StorageService.write(StorageKeys.selectedPatientUhid, patient.uhid);
    await StorageService.write(
      StorageKeys.selectedPatientEmiratesId,
      patient.emiratesId ?? '',
    );
  }

  Future<void> clear() async {
    selected.value = null;
    await StorageService.remove(StorageKeys.selectedPatient);
    await StorageService.remove(StorageKeys.selectedPatientId);
    await StorageService.remove(StorageKeys.selectedPatientName);
    await StorageService.remove(StorageKeys.selectedPatientMrn);
    await StorageService.remove(StorageKeys.selectedPatientUhid);
    await StorageService.remove(StorageKeys.selectedPatientEmiratesId);
    await _clearEncounter();
  }

  Future<void> _clearEncounter() async {
    if (Get.isRegistered<SelectedEncounterController>()) {
      await Get.find<SelectedEncounterController>().clear();
    }
  }

  bool isSelected(PatientModel patient) =>
      selected.value?.id == patient.id || selected.value?.uhid == patient.uhid;

  /// UUID used by engine-check and other patient-scoped APIs.
  String get patientId => selected.value?.id ??
      StorageService.read<String>(StorageKeys.selectedPatientId) ??
      '';

  String get displayName =>
      selected.value?.name ??
      StorageService.read<String>(StorageKeys.selectedPatientName) ??
      '';

  String get displayMeta {
    final p = selected.value;
    if (p != null) return p.uhid;
    return StorageService.read<String>(StorageKeys.selectedPatientMrn) ?? '';
  }

  String get mrn =>
      selected.value?.uhid ??
      StorageService.read<String>(StorageKeys.selectedPatientMrn) ??
      '';
}
