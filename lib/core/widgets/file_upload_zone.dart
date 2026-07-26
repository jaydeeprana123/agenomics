import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/document_model.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class FileUploadZone extends StatelessWidget {
  final String title;
  final String hint;
  final bool allowMultiple;
  final VoidCallback onPick;
  final List<DocumentModel> files;
  final void Function(DocumentModel doc) onDelete;
  final void Function(DocumentModel doc)? onPreview;
  final DocumentModel? uploading;
  final double uploadProgress;

  const FileUploadZone({
    super.key,
    required this.title,
    required this.hint,
    required this.onPick,
    required this.files,
    required this.onDelete,
    this.onPreview,
    this.allowMultiple = false,
    this.uploading,
    this.uploadProgress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(
                color: AppColors.primaryMid,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined,
                    size: 32, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  allowMultiple ? 'Click to upload files' : 'Click to upload file',
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (uploading != null) ...[
          const SizedBox(height: 10),
          _UploadProgressTile(
            fileName: uploading!.fileName,
            progress: uploadProgress,
          ),
        ],
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DocumentTile(
                document: doc,
                onDelete: () => onDelete(doc),
                onPreview: onPreview != null ? () => onPreview!(doc) : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadProgressTile extends StatelessWidget {
  final String fileName;
  final double progress;

  const _UploadProgressTile({
    required this.fileName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onDelete;
  final VoidCallback? onPreview;

  const _DocumentTile({
    required this.document,
    required this.onDelete,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, HH:mm').format(document.uploadedAt);
    final isVcf = document.fileExtension == 'vcf';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isVcf ? AppColors.purpleBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isVcf ? Icons.biotech_outlined : Icons.picture_as_pdf_outlined,
              size: 18,
              color: isVcf ? AppColors.purple : AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded $date',
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onPreview != null)
            AppButton(
              label: 'Preview',
              variant: AppButtonVariant.ghost,
              icon: Icons.visibility_outlined,
              onPressed: onPreview,
              height: 32,
            ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
