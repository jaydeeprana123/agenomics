import 'package:flutter/foundation.dart';

/// Centralized API endpoints (Agenomics OpenAPI).
class ApiEndpoints {
  ApiEndpoints._();

  /// Real API host (Windows / Android / iOS).
  // static const String remoteBaseUrl =
  //     'https://apis.agenomicsapi.com';

  static const String remoteBaseUrl =
      'https://3a1e-115-246-26-2.ngrok-free.app';

  /// Local bridge for Flutter Web only — browsers block cross-origin
  /// calls when the API has no CORS headers.
  /// Start with: dart run tool/api_proxy.dart
  static const String webProxyBaseUrl = 'http://localhost:8090';

  /// Web → local proxy → ngrok. Native → ngrok directly.
  static String get baseUrl => kIsWeb ? remoteBaseUrl : remoteBaseUrl;

  // Auth
  static const String login = '/api/v1/auth/login';

  // Patients
  static const String patients = '/api/v1/patients';
  static String patient(String uhid) => '/api/v1/patients/$uhid';
  static String engineCheck(String patientId) =>
      '/api/v1/patients/$patientId/engine-check';
  static String pgxResults(String patientId) =>
      '/api/v1/patients/$patientId/pgx-results';
  static String patientEncounters(String patientId) =>
      '/api/v1/patients/$patientId/encounters';
  static String encounter(String encounterId) =>
      '/api/v1/encounters/$encounterId';

  // Medicines
  static const String medicines = '/api/v1/medicines';
  static String medicine(String medicineId) => '/api/v1/medicines/$medicineId';

  // Documents (future)
  static String patientDocuments(String patientId) =>
      '/api/v1/patients/$patientId/documents';
  static String document(String patientId, String documentId) =>
      '/api/v1/patients/$patientId/documents/$documentId';
  static String uploadGenomics(String patientId) =>
      '/api/v1/patients/$patientId/documents/genomics';
  static String uploadReports(String patientId) =>
      '/api/v1/patients/$patientId/documents/reports';

  // Genomiki VCF jobs
  static const String genomikiJobs = '/api/v1/integrations/genomiki/jobs';
  static String genomikiJob(String genomikiJobId) =>
      '/api/v1/integrations/genomiki/jobs/$genomikiJobId';
  static String genomikiJobStatus(String genomikiJobId) =>
      '/api/v1/integrations/genomiki/jobs/$genomikiJobId/status';
  static String genomikiJobRefresh(String genomikiJobId) =>
      '/api/v1/integrations/genomiki/jobs/$genomikiJobId/refresh';

  /// Genomiki PDF ingest — InheriGene PGx / OnQuer oncology.
  static const String reportsPdf = '/api/v1/integrations/reports/pdf';
}
