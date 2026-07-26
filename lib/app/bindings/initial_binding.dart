import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/repositories/patient_repository.dart';
import '../../modules/shell/controllers/selected_patient_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<PatientRepository>(PatientRepository(), permanent: true);
    Get.put<DocumentRepository>(DocumentRepository(), permanent: true);
    Get.put<MedicineRepository>(MedicineRepository(), permanent: true);
    Get.put<SelectedPatientController>(
      SelectedPatientController(),
      permanent: true,
    );
  }
}
