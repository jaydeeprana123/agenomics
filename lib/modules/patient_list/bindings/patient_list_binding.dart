import 'package:get/get.dart';

import '../controllers/patient_list_controller.dart';

class PatientListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PatientListController>()) {
      Get.put(PatientListController(), permanent: true);
    }
  }
}
