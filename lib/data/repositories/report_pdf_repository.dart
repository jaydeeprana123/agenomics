import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/report_pdf_result_model.dart';

/// Genomiki PDF ingest — `POST /api/v1/integrations/reports/pdf`.
class ReportPdfRepository {
  Future<ReportPdfResult> ingestReportPdf({
    required String patientId,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    bool includePatientDetails = true,
  }) async {
    if ((filePath == null || filePath.isEmpty) &&
        (fileBytes == null || fileBytes.isEmpty)) {
      throw const ApiException('No PDF file selected.');
    }

    try {
      final MultipartFile file;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        file = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
      } else {
        file = await MultipartFile.fromFile(
          filePath!,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({
        'patient_id': patientId,
        'include_patient_details': includePatientDetails,
        'file': file,
      });

      final response = await DioClient.instance.post(
        ApiEndpoints.reportsPdf,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
          headers: const {'Accept': '*/*'},
        ),
      );

      return _parseResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  ReportPdfResult _parseResponse(Response<dynamic> response) {
    final raw = response.data;
    final contentType =
        (response.headers.value('content-type') ?? '').toLowerCase();

    Uint8List? asBytes;
    if (raw is Uint8List) {
      asBytes = raw;
    } else if (raw is List<int>) {
      asBytes = Uint8List.fromList(raw);
    }

    if (asBytes != null) {
      if (contentType.contains('pdf') || ReportPdfResult.looksLikePdf(asBytes)) {
        return ReportPdfResult.fromBytes(asBytes);
      }

      final json = ReportPdfResult.tryDecodeJson(asBytes);
      if (json != null) {
        _throwIfErrorPayload(json, response.statusCode);
        return ReportPdfResult.fromJson(json);
      }

      // Unknown binary payload — treat as PDF if non-empty.
      if (asBytes.isNotEmpty) {
        return ReportPdfResult.fromBytes(asBytes);
      }
    }

    if (raw is Map) {
      final json = Map<String, dynamic>.from(raw);
      _throwIfErrorPayload(json, response.statusCode);
      return ReportPdfResult.fromJson(json);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final json = ReportPdfResult.tryDecodeJson(raw.codeUnits);
      if (json != null) {
        _throwIfErrorPayload(json, response.statusCode);
        return ReportPdfResult.fromJson(json);
      }
      return ReportPdfResult(message: raw.trim());
    }

    return const ReportPdfResult(message: 'Report processed successfully.');
  }

  void _throwIfErrorPayload(Map<String, dynamic> json, int? statusCode) {
    final detail = json['detail'];
    if (detail is String && detail.trim().isNotEmpty && (statusCode ?? 200) >= 400) {
      throw ApiException(detail, statusCode: statusCode);
    }
  }
}
