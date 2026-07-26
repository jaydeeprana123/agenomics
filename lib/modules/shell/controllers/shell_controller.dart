import 'package:get/get.dart';

class ShellController extends GetxController {
  final title = 'Patients'.obs;

  void setTitle(String value) => title.value = value;
}
