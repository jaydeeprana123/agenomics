import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/file_upload_zone.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/document_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/upload_documents_controller.dart';

class UploadDocumentsView extends GetView<UploadDocumentsController> {
  const UploadDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = controller.patient;
    if (patient == null) {
      return const AppShell(
        title: 'Upload Documents',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final isWide =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    return AppShell(
      title: 'Upload Documents — ${patient.name}',
      child: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: 'Upload Documents',
                subtitle:
                    'Attach genomics file and clinical reports for claim processing.',
                actions: [
                  AppButton(
                    label: 'Back',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.arrow_back,
                    onPressed: controller.goBack,
                  ),
                  AppButton(
                    label: 'Finish',
                    icon: Icons.check,
                    onPressed: controller.finish,
                  ),
                ],
              ),
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        patient.name.isNotEmpty
                            ? patient.name[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Text(
                                patient.patientId,
                                style: const TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                patient.mobile,
                                style: const TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                [
                                  if (patient.gender.isNotEmpty) patient.gender,
                                  if (patient.age != null) '${patient.age} yrs',
                                ].join(' · '),
                                style: const TextStyle(
                                  fontFamily: 'Mulish',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                      label: 'Document Upload',
                      type: StatusBadgeType.teal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _genomicsCard(patient.id)),
                    const SizedBox(width: 14),
                    Expanded(child: _reportsCard(patient.id)),
                  ],
                )
              else ...[
                _genomicsCard(patient.id),
                const SizedBox(height: 14),
                _reportsCard(patient.id),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Back',
                    variant: AppButtonVariant.secondary,
                    onPressed: controller.goBack,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: 'Finish',
                    icon: Icons.check_circle_outline,
                    onPressed: controller.finish,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genomicsCard(String patientId) {
    return AppCard(
      child: Obx(
        () => FileUploadZone(
          title: 'UPLOAD GENOMICS FILE',
          hint: 'Single PDF or VCF file',
          allowMultiple: false,
          onPick: controller.pickGenomicsFile,
          files: controller.genomicsFiles.toList(),
          onDelete: controller.deleteDocument,
          onPreview: controller.previewDocument,
          uploading: controller.uploadingGenomics.value
              ? DocumentModel(
                  id: 'temp',
                  patientId: patientId,
                  fileName: controller.uploadingFileName.value,
                  type: DocumentType.genomics,
                  mimeType: 'application/octet-stream',
                  uploadedAt: DateTime.now(),
                  isUploaded: false,
                  uploadProgress: controller.genomicsProgress.value,
                )
              : null,
          uploadProgress: controller.genomicsProgress.value,
        ),
      ),
    );
  }

  Widget _reportsCard(String patientId) {
    return AppCard(
      child: Obx(
        () => FileUploadZone(
          title: 'UPLOAD REPORTS',
          hint: 'One or more PDF reports',
          allowMultiple: true,
          onPick: controller.pickReportFiles,
          files: controller.reportFiles.toList(),
          onDelete: controller.deleteDocument,
          onPreview: controller.previewDocument,
          uploading: controller.uploadingReports.value
              ? DocumentModel(
                  id: 'temp',
                  patientId: patientId,
                  fileName: controller.uploadingFileName.value,
                  type: DocumentType.report,
                  mimeType: 'application/pdf',
                  uploadedAt: DateTime.now(),
                  isUploaded: false,
                  uploadProgress: controller.reportsProgress.value,
                )
              : null,
          uploadProgress: controller.reportsProgress.value,
        ),
      ),
    );
  }
}
