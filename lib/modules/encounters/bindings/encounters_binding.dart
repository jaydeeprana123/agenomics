import 'package:get/get.dart';

import '../controllers/encounters_controller.dart';

class EncountersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EncountersController>(() => EncountersController());
  }
}
