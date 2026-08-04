import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/fcm_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/consent_request_model.dart';
import '../../../data/repositories/consent_repository.dart';
import '../../../app/routes/app_routes.dart';

/// Mobile consent tablet — continuously listens for pending desktop requests.
class ConsentInboxController extends GetxController {
  ConsentInboxController({
    ConsentRepository? repository,
    FcmService? fcm,
  })  : _repository = repository ?? Get.find<ConsentRepository>(),
        _fcm = fcm;

  final ConsentRepository _repository;
  FcmService? _fcm;

  final pending = <ConsentRequestModel>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  StreamSubscription<List<ConsentRequestModel>>? _sub;
  final Set<String> _seenIds = {};
  bool _firstSnapshot = true;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  Future<void> _startListening() async {
    isLoading.value = true;
    error.value = '';
    try {
      _fcm ??= Get.isRegistered<FcmService>() ? Get.find<FcmService>() : null;
      await _fcm?.init();
    } catch (e) {
      // FCM is best-effort; Firestore stream is the source of truth.
      error.value = '';
    }

    _sub?.cancel();
    _sub = _repository.watchPendingRequests().listen(
      (list) {
        if (!_firstSnapshot) {
          for (final item in list) {
            if (!_seenIds.contains(item.id)) {
              _fcm?.notifyNewConsent(
                patientName: item.patientName,
                uhid: item.patientUhid,
              );
            }
          }
        }
        _firstSnapshot = false;
        _seenIds
          ..clear()
          ..addAll(list.map((e) => e.id));
        pending.assignAll(list);
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> openRequest(ConsentRequestModel request) async {
    final result = await Get.toNamed(
      AppRoutes.consentForm,
      arguments: request,
    );
    if (result == ConsentStatus.approved || result == ConsentStatus.declined) {
      // Stream will refresh automatically.
    }
  }

  void showStatusSnack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.panel,
      colorText: AppColors.darkInk,
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
