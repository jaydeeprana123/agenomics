import 'package:get/get.dart';

import '../controllers/physician_his_controller.dart';

class PhysicianHisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhysicianHisController>(() => PhysicianHisController());
  }
}
