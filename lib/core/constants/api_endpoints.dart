import 'package:flutter/foundation.dart';

/// Centralized API endpoints (Agenomics OpenAPI).
class ApiEndpoints {
  ApiEndpoints._();

  /// Real API host (Windows / Android / iOS).
  static const String remoteBaseUrl =
      'https://32dd-115-246-26-2.ngrok-free.app';

  /// Local bridge for Flutter Web only — browsers block cross-origin
  /// calls when the API has no CORS headers.
  /// Start with: dart run tool/api_proxy.dart
  static const String webProxyBaseUrl = 'http://localhost:8090';

  /// Web → local proxy → ngrok. Native → ngrok directly.
  static String get baseUrl => kIsWeb ? webProxyBaseUrl : remoteBaseUrl;

  // Auth
  static const String login = '/api/v1/auth/login';

  // Patients
  static const String patients = '/api/v1/patients';
  static String patient(String uhid) => '/api/v1/patients/$uhid';

  // Documents (future)
  static String patientDocuments(String patientId) =>
      '/api/v1/patients/$patientId/documents';
  static String document(String patientId, String documentId) =>
      '/api/v1/patients/$patientId/documents/$documentId';
  static String uploadGenomics(String patientId) =>
      '/api/v1/patients/$patientId/documents/genomics';
  static String uploadReports(String patientId) =>
      '/api/v1/patients/$patientId/documents/reports';
}
