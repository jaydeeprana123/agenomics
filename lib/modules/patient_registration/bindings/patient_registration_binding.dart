import 'package:get/get.dart';

import '../controllers/patient_registration_controller.dart';

class PatientRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientRegistrationController>(
      () => PatientRegistrationController(),
    );
  }
}
