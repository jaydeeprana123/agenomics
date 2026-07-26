import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/document_repository.dart';

class UploadDocumentsController extends GetxController {
  final DocumentRepository _repository = Get.find<DocumentRepository>();

  PatientModel? patient;

  final genomicsFiles = <DocumentModel>[].obs;
  final reportFiles = <DocumentModel>[].obs;
  final isLoading = false.obs;

  final uploadingGenomics = false.obs;
  final uploadingReports = false.obs;
  final genomicsProgress = 0.0.obs;
  final reportsProgress = 0.0.obs;
  final uploadingFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! PatientModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.patientList);
      });
      return;
    }
    patient = args;
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    final p = patient;
    if (p == null) return;

    isLoading.value = true;
    try {
      final docs = await _repository.getDocuments(p.id);
      genomicsFiles.assignAll(
        docs.where((d) => d.type == DocumentType.genomics),
      );
      reportFiles.assignAll(
        docs.where((d) => d.type == DocumentType.report),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickGenomicsFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'vcf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    await _upload(
      fileName: file.name,
      filePath: file.path,
      fileSize: file.size,
      type: DocumentType.genomics,
    );
  }

  Future<void> pickReportFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    for (final file in result.files) {
      await _upload(
        fileName: file.name,
        filePath: file.path,
        fileSize: file.size,
        type: DocumentType.report,
      );
    }
  }

  Future<void> _upload({
    required String fileName,
    required String? filePath,
    required int? fileSize,
    required DocumentType type,
  }) async {
    final p = patient;
    if (p == null) return;

    final isGenomics = type == DocumentType.genomics;
    if (isGenomics) {
      uploadingGenomics.value = true;
      genomicsProgress.value = 0;
    } else {
      uploadingReports.value = true;
      reportsProgress.value = 0;
    }
    uploadingFileName.value = fileName;

    try {
      final doc = await _repository.uploadDocument(
        patientId: p.id,
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        type: type,
        onProgress: (progress) {
          if (isGenomics) {
            genomicsProgress.value = progress;
          } else {
            reportsProgress.value = progress;
          }
        },
      );

      if (isGenomics) {
        genomicsFiles.assignAll([doc]);
      } else {
        reportFiles.add(doc);
      }

      Get.snackbar(
        'Uploaded',
        '$fileName uploaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'Upload failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      uploadingGenomics.value = false;
      uploadingReports.value = false;
      uploadingFileName.value = '';
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    final p = patient;
    if (p == null) return;

    try {
      await _repository.deleteDocument(
        patientId: p.id,
        documentId: doc.id,
      );
      if (doc.type == DocumentType.genomics) {
        genomicsFiles.clear();
      } else {
        reportFiles.removeWhere((d) => d.id == doc.id);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    }
  }

  void previewDocument(DocumentModel doc) {
    Get.dialog(
      AlertDialog(
        title: const Text('Document preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${doc.fileName}'),
            const SizedBox(height: 6),
            Text(
              'Type: ${doc.type == DocumentType.genomics ? 'Genomics' : 'Report'}',
            ),
            const SizedBox(height: 6),
            Text('Path: ${doc.filePath ?? 'Local (demo)'}'),
            const SizedBox(height: 12),
            const Text(
              'Full preview will open when the document viewer API is connected.',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void goBack() => Get.back();

  void finish() {
    if (Get.currentRoute == AppRoutes.patientList) return;
    Get.until(
      (route) =>
          route.settings.name == AppRoutes.patientList || route.isFirst,
    );
  }
}
