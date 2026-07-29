import 'package:get/get.dart';

import '../controllers/genomics_analysis_controller.dart';

class GenomicsAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenomicsAnalysisController>(() => GenomicsAnalysisController());
  }
}
