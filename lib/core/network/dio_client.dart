import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../modules/patient_list/controllers/patient_list_controller.dart';
import '../../modules/shell/controllers/selected_encounter_controller.dart';
import '../../modules/shell/controllers/selected_patient_controller.dart';
import '../constants/api_endpoints.dart';
import '../storage/storage_service.dart';
import 'api_logger.dart';

/// Central Dio client configured for the Agenomics API.
class DioClient {
  DioClient._();

  static Dio? _dio;
  static bool _handlingUnauthorized = false;

  static Dio get instance {
    _dio ??= _create();
    return _dio!;
  }

  static void reset() {
    _dio?.close(force: true);
    _dio = null;
  }

  static Dio _create() {
    final headers = <String, dynamic>{
      'Accept': 'application/json',
    };

    // Custom headers force a CORS preflight on web. The proxy adds
    // ngrok-skip-browser-warning when forwarding.
    if (!kIsWeb) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: kIsWeb ? null : const Duration(seconds: 60),
        headers: headers,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          ApiLogger.logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          ApiLogger.logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) async {
          ApiLogger.logError(error);
          if (kDebugMode &&
              kIsWeb &&
              error.type == DioExceptionType.connectionError) {
            debugPrint(
              '[API HINT] Flutter Web needs the local bridge. '
              'Run: dart run tool/api_proxy.dart '
              '(forwards to ${ApiEndpoints.remoteBaseUrl})',
            );
          }

          if (_isUnauthorized(error)) {
            await _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool _isUnauthorized(DioException error) {
    if (error.response?.statusCode != 401) return false;
    // Failed login credentials must not trigger a session logout.
    final path = error.requestOptions.path;
    if (path.contains(ApiEndpoints.login)) return false;
    return true;
  }

  /// Clears session state and sends the user to login (once per burst of 401s).
  static Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    try {
      if (Get.isRegistered<SelectedPatientController>()) {
        await Get.find<SelectedPatientController>().clear();
      } else if (Get.isRegistered<SelectedEncounterController>()) {
        await Get.find<SelectedEncounterController>().clear();
      }

      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().logout();
      } else {
        await StorageService.clearAuth();
      }

      if (Get.isRegistered<PatientListController>()) {
        Get.delete<PatientListController>(force: true);
      }

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      _handlingUnauthorized = false;
    }
  }

  static Future<Response<T>> uploadMultipart<T>({
    required String path,
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return instance.post<T>(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
