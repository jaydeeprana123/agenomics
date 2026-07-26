import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../models/document_model.dart';

/// Document repository — dummy uploads until Laravel multipart APIs are ready.
class DocumentRepository {
  static final Map<String, List<DocumentModel>> _docsByPatient = {};
  int _nextId = 1;

  Future<List<DocumentModel>> getDocuments(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_docsByPatient[patientId] ?? []);
  }

  /// Validates extension for genomics (pdf/vcf) or reports (pdf).
  bool isValidFile({
    required String fileName,
    required DocumentType type,
  }) {
    final ext = p.extension(fileName).toLowerCase().replaceFirst('.', '');
    if (type == DocumentType.genomics) {
      return ext == 'pdf' || ext == 'vcf';
    }
    return ext == 'pdf';
  }

  /// Simulates multipart upload with progress. Ready for DioClient.uploadMultipart.
  Future<DocumentModel> uploadDocument({
    required String patientId,
    required String fileName,
    required String? filePath,
    required DocumentType type,
    int? fileSize,
    void Function(double progress)? onProgress,
  }) async {
    if (!isValidFile(fileName: fileName, type: type)) {
      final allowed =
          type == DocumentType.genomics ? 'PDF or VCF' : 'PDF';
      throw Exception('Unsupported file format. Allowed: $allowed');
    }

    if (type == DocumentType.genomics) {
      final existing = _docsByPatient[patientId] ?? [];
      if (existing.any((d) => d.type == DocumentType.genomics)) {
        throw Exception('Only one genomics file is allowed. Delete the existing one first.');
      }
    }

    // Simulate upload progress for future API integration UI.
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      onProgress?.call(i / 10);
    }

    // Multipart upload is prepared via DioClient.uploadMultipart + buildMultipartForm.
    // Swap the simulated loop above with a real API call when Laravel endpoints are live.

    final mime = fileName.toLowerCase().endsWith('.vcf')
        ? 'text/x-vcf'
        : 'application/pdf';

    final doc = DocumentModel(
      id: '${_nextId++}',
      patientId: patientId,
      fileName: fileName,
      filePath: filePath,
      type: type,
      mimeType: mime,
      fileSize: fileSize,
      uploadedAt: DateTime.now(),
      uploadProgress: 1.0,
      isUploaded: true,
    );

    _docsByPatient.putIfAbsent(patientId, () => []);
    _docsByPatient[patientId]!.add(doc);

    return doc;
  }

  Future<void> deleteDocument({
    required String patientId,
    required String documentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _docsByPatient[patientId]
        ?.removeWhere((d) => d.id == documentId);
  }

  /// Builds FormData for real API multipart uploads (unused until APIs live).
  Future<FormData> buildMultipartForm({
    required String filePath,
    required String fileName,
    required DocumentType type,
  }) async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'type': type == DocumentType.genomics ? 'genomics' : 'report',
    });
  }
}
