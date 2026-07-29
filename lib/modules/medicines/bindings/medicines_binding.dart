import 'package:get/get.dart';

import '../controllers/medicines_controller.dart';

class MedicinesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicinesController>(() => MedicinesController());
  }
}
