import 'package:get/get.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/encounter_model.dart';

/// Global selected visit/encounter — available on every screen via GetX + GetStorage.
class SelectedEncounterController extends GetxController {
  final selected = Rxn<EncounterModel>();

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final data = StorageService.read(StorageKeys.selectedEncounter);
    if (data is Map) {
      try {
        final encounter =
            EncounterModel.fromJson(Map<String, dynamic>.from(data));
        selected.value = encounter;
        _writeIndividualKeys(encounter);
      } catch (_) {
        selected.value = null;
      }
    }
  }

  Future<void> select(EncounterModel encounter) async {
    selected.value = encounter;
    await StorageService.write(
      StorageKeys.selectedEncounter,
      encounter.toJson(),
    );
    await _writeIndividualKeys(encounter);
  }

  Future<void> _writeIndividualKeys(EncounterModel encounter) async {
    await StorageService.write(StorageKeys.selectedEncounterId, encounter.id);
    await StorageService.write(
      StorageKeys.selectedEncounterVisitId,
      encounter.visitId,
    );
    await StorageService.write(
      StorageKeys.selectedEncounterPatientId,
      encounter.patientId,
    );
  }

  Future<void> clear() async {
    selected.value = null;
    await StorageService.remove(StorageKeys.selectedEncounter);
    await StorageService.remove(StorageKeys.selectedEncounterId);
    await StorageService.remove(StorageKeys.selectedEncounterVisitId);
    await StorageService.remove(StorageKeys.selectedEncounterPatientId);
  }

  /// Drop the visit if it belongs to a different patient (or none).
  Future<void> clearIfNotForPatient(String? patientId) async {
    final current = selected.value;
    if (current == null) return;
    if (patientId == null ||
        patientId.isEmpty ||
        current.patientId != patientId) {
      await clear();
    }
  }

  bool isSelected(EncounterModel encounter) =>
      selected.value?.id == encounter.id;

  String get encounterId =>
      selected.value?.id ??
      StorageService.read<String>(StorageKeys.selectedEncounterId) ??
      '';

  String get displayLabel =>
      selected.value?.displayLabel ??
      StorageService.read<String>(StorageKeys.selectedEncounterVisitId) ??
      '';
}
