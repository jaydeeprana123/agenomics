import 'package:get/get.dart';

import '../../modules/encounters/bindings/encounters_binding.dart';
import '../../modules/encounters/views/encounters_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/patient_list/bindings/patient_list_binding.dart';
import '../../modules/patient_list/views/patient_list_view.dart';
import '../../modules/patient_registration/bindings/patient_registration_binding.dart';
import '../../modules/patient_registration/views/patient_registration_view.dart';
import '../../modules/genomics_analysis/bindings/genomics_analysis_binding.dart';
import '../../modules/genomics_analysis/views/genomics_analysis_view.dart';
import '../../modules/medicines/bindings/medicines_binding.dart';
import '../../modules/medicines/views/medicines_view.dart';
import '../../modules/physician_his/bindings/physician_his_binding.dart';
import '../../modules/physician_his/views/physician_his_view.dart';
import '../../modules/upload_documents/bindings/upload_documents_binding.dart';
import '../../modules/upload_documents/views/upload_documents_view.dart';
import '../../modules/vcf_file_run/bindings/vcf_file_run_binding.dart';
import '../../modules/vcf_file_run/views/vcf_file_run_view.dart';
import '../../modules/consent/bindings/consent_binding.dart';
import '../../modules/consent/views/consent_form_view.dart';
import '../../modules/consent/views/consent_inbox_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.patientList,
      page: () => const PatientListView(),
      binding: PatientListBinding(),
    ),
    GetPage(
      name: AppRoutes.patientRegistration,
      page: () => const PatientRegistrationView(),
      binding: PatientRegistrationBinding(),
    ),
    GetPage(
      name: AppRoutes.patientEdit,
      page: () => const PatientRegistrationView(),
      binding: PatientRegistrationBinding(),
    ),
    GetPage(
      name: AppRoutes.uploadDocuments,
      page: () => const UploadDocumentsView(),
      binding: UploadDocumentsBinding(),
    ),
    GetPage(
      name: AppRoutes.encounters,
      page: () => const EncountersView(),
      binding: EncountersBinding(),
    ),
    GetPage(
      name: AppRoutes.physicianHis,
      page: () => const PhysicianHisView(),
      binding: PhysicianHisBinding(),
    ),
    GetPage(
      name: AppRoutes.genomicsAnalysis,
      page: () => const GenomicsAnalysisView(),
      binding: GenomicsAnalysisBinding(),
    ),
    GetPage(
      name: AppRoutes.medicines,
      page: () => const MedicinesView(),
      binding: MedicinesBinding(),
    ),
    GetPage(
      name: AppRoutes.vcfFileRun,
      page: () => const VcfFileRunView(),
      binding: VcfFileRunBinding(),
    ),
    GetPage(
      name: AppRoutes.consentInbox,
      page: () => const ConsentInboxView(),
      binding: ConsentInboxBinding(),
    ),
    GetPage(
      name: AppRoutes.consentForm,
      page: () => const ConsentFormView(),
      binding: ConsentFormBinding(),
    ),
  ];
}
