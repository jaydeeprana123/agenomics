import 'package:get/get.dart';

import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/patient_list/bindings/patient_list_binding.dart';
import '../../modules/patient_list/views/patient_list_view.dart';
import '../../modules/patient_registration/bindings/patient_registration_binding.dart';
import '../../modules/patient_registration/views/patient_registration_view.dart';
import '../../modules/physician_his/bindings/physician_his_binding.dart';
import '../../modules/physician_his/views/physician_his_view.dart';
import '../../modules/upload_documents/bindings/upload_documents_binding.dart';
import '../../modules/upload_documents/views/upload_documents_view.dart';
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
      name: AppRoutes.physicianHis,
      page: () => const PhysicianHisView(),
      binding: PhysicianHisBinding(),
    ),
  ];
}
