import 'package:get/get.dart';

import '../controllers/vcf_file_run_controller.dart';

class VcfFileRunBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VcfFileRunController>(() => VcfFileRunController());
  }
}
