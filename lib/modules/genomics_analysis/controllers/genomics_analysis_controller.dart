import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/pdf_file_helper.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/models/pgx_result_model.dart';
import '../../../data/repositories/pgx_repository.dart';
import '../../../data/repositories/report_pdf_repository.dart';
import '../../shell/controllers/selected_patient_controller.dart';

class GenomicsAnalysisController extends GetxController {
  GenomicsAnalysisController({
    PgxRepository? pgxRepository,
    ReportPdfRepository? reportPdfRepository,
  })  : _repository = pgxRepository ?? Get.find<PgxRepository>(),
        _reportPdfRepository =
            reportPdfRepository ?? Get.find<ReportPdfRepository>();

  final PgxRepository _repository;
  final ReportPdfRepository _reportPdfRepository;
  final SelectedPatientController selectedPatient =
      Get.find<SelectedPatientController>();

  final results = <PgxResultModel>[].obs;
  final panelRows = <PgxPanelRow>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isDownloadingPdf = false.obs;
  final errorMessage = RxnString();

  PatientModel? get patient => selectedPatient.selected.value;

  String get sourceLabel {
    final fromResults = results
        .map((r) => r.dataSource?.trim() ?? '')
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (fromResults.isNotEmpty) {
      switch (fromResults.toLowerCase()) {
        case 'pharmcat':
          return 'PharmCAT';
        case 'hl7':
          return 'Malaffi HIE';
        case 'fhir':
          return 'FHIR R4 · HIE';
        default:
          return fromResults;
      }
    }

    final source = patient?.source.trim() ?? '';
    if (source.isEmpty) return 'Malaffi HIE';
    switch (source.toLowerCase()) {
      case 'hl7':
        return 'Malaffi HIE';
      case 'fhir':
        return 'FHIR R4 · HIE';
      case 'vcf':
        return '3rd-party VCF';
      case 'manual':
        return 'Manual entry';
      default:
        return source;
    }
  }

  String get pharmCatRunLabel {
    final processed = results.map((r) => r.pharmcatProcessed).whereType<bool>();
    if (processed.any((v) => v)) return 'Yes — on-edge';
    if (processed.isNotEmpty) return 'No — pre-interpreted';

    final source = (patient?.source ?? '').toLowerCase();
    if (source.contains('vcf')) return 'Yes — on-edge';
    return 'No — pre-interpreted';
  }

  @override
  void onInit() {
    super.onInit();
    if (patient == null || (patient?.id.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Select a patient',
          'Choose a patient from the Patient List before opening Genomic Analysis.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.text,
        );
        Get.offNamed(AppRoutes.patientList);
      });
      return;
    }

    loadResults();
  }

  Future<void> loadResults({bool refresh = false}) async {
    if (isClosed) return;

    final current = patient;
    if (current == null || current.id.isEmpty) {
      errorMessage.value = 'No patient selected.';
      return;
    }

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final list = await _repository.getPgxResults(current.id);
      if (isClosed) return;
      results.assignAll(list);
      panelRows.assignAll(PgxPanelRow.fromResults(list));
    } on ApiException catch (e) {
      if (isClosed) return;
      if (e.statusCode == 401) {
        errorMessage.value = 'Session expired. Please sign in again.';
      } else {
        errorMessage.value = e.message;
      }
      Get.snackbar(
        'Unable to load PGx results',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      if (isClosed) return;
      errorMessage.value = 'Unexpected error while loading PGx results.';
      Get.snackbar(
        'Unable to load PGx results',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  /// Calls `POST /api/v1/integrations/reports/pdf` for the selected patient.
  ///
  /// Picks an InheriGene / OnQuer Genomiki PDF, uploads it with patient details,
  /// then opens/saves any returned PDF URL or bytes and refreshes PGx results.
  Future<void> downloadPdfReport() async {
    if (isClosed || isDownloadingPdf.value) return;

    final current = patient;
    if (current == null || current.id.isEmpty) {
      Get.snackbar(
        'Select a patient',
        'Choose a patient before downloading a PDF report.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return;
    }

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;
    final fileName = file.name.trim().isEmpty ? 'report.pdf' : file.name;
    final bytes = file.bytes;
    final path = file.path;

    if ((bytes == null || bytes.isEmpty) && (path == null || path.isEmpty)) {
      Get.snackbar(
        'Unable to read file',
        'Could not read the selected PDF. Please try another file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return;
    }

    isDownloadingPdf.value = true;

    try {
      final result = await _reportPdfRepository.ingestReportPdf(
        patientId: current.id,
        fileName: fileName,
        filePath: path,
        fileBytes: bytes,
        includePatientDetails: true,
      );

      if (isClosed) return;

      String successDetail =
          result.message?.trim().isNotEmpty == true
              ? result.message!.trim()
              : 'Report generated successfully.';

      if (result.reportType != null && result.reportType!.trim().isNotEmpty) {
        successDetail = '$successDetail (${result.reportType})';
      }

      if (result.hasPdfUrl) {
        final outName = PdfFileHelper.defaultFileName(
          patientName: current.name,
          uhid: current.uhid,
        );
        final savedPath = await PdfFileHelper.openOrDownloadPdfUrl(
          url: result.url!,
          fileName: outName,
        );
        successDetail = savedPath == null
            ? 'Report generated successfully. The PDF was opened in a new tab.'
            : 'Report generated successfully. ${PdfFileHelper.platformSaveHint(savedPath)}';
      } else if (result.hasPdfBytes) {
        final outName = PdfFileHelper.defaultFileName(
          patientName: current.name,
          uhid: current.uhid,
        );
        final savedPath = await PdfFileHelper.savePdfBytes(
          bytes: result.bytes!,
          fileName: outName,
        );
        successDetail =
            'Report generated successfully. ${PdfFileHelper.platformSaveHint(savedPath)}';
      }

      Get.snackbar(
        'PDF report ready',
        successDetail,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
        duration: const Duration(seconds: 4),
      );

      // InheriGene ingest writes into patient_pgx_results — refresh the panel.
      await loadResults(refresh: true);
    } on ApiException catch (e) {
      if (isClosed) return;
      Get.snackbar(
        'Unable to generate PDF report',
        e.statusCode == 401
            ? 'Session expired. Please sign in again.'
            : e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      if (isClosed) return;
      Get.snackbar(
        'Unable to generate PDF report',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) {
        isDownloadingPdf.value = false;
      }
    }
  }
}
