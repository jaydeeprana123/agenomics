import 'package:get/get.dart';

import '../../../core/services/fcm_service.dart';
import '../../../data/repositories/consent_repository.dart';
import '../controllers/consent_form_controller.dart';
import '../controllers/consent_inbox_controller.dart';

class ConsentFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConsentRepository>()) {
      Get.put<ConsentRepository>(ConsentRepository(), permanent: true);
    }
    Get.lazyPut<ConsentFormController>(() => ConsentFormController());
  }
}

class ConsentInboxBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConsentRepository>()) {
      Get.put<ConsentRepository>(ConsentRepository(), permanent: true);
    }
    if (!Get.isRegistered<FcmService>()) {
      Get.put<FcmService>(FcmService(Get.find<ConsentRepository>()), permanent: true);
    }
    Get.lazyPut<ConsentInboxController>(() => ConsentInboxController());
  }
}
