import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/consent_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/encounter_repository.dart';
import '../../data/repositories/genomiki_repository.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/repositories/pgx_repository.dart';
import '../../data/repositories/report_pdf_repository.dart';
import '../../modules/consent/controllers/consent_desktop_controller.dart';
import '../../modules/shell/controllers/selected_encounter_controller.dart';
import '../../modules/shell/controllers/selected_patient_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<PatientRepository>(PatientRepository(), permanent: true);
    Get.put<DocumentRepository>(DocumentRepository(), permanent: true);
    Get.put<MedicineRepository>(MedicineRepository(), permanent: true);
    Get.put<EncounterRepository>(EncounterRepository(), permanent: true);
    Get.put<PgxRepository>(PgxRepository(), permanent: true);
    Get.put<ReportPdfRepository>(ReportPdfRepository(), permanent: true);
    Get.put<GenomikiRepository>(GenomikiRepository(), permanent: true);
    Get.put<ConsentRepository>(ConsentRepository(), permanent: true);
    Get.put<ConsentDesktopController>(
      ConsentDesktopController(),
      permanent: true,
    );
    Get.put<SelectedPatientController>(
      SelectedPatientController(),
      permanent: true,
    );
    Get.put<SelectedEncounterController>(
      SelectedEncounterController(),
      permanent: true,
    );
  }
}
