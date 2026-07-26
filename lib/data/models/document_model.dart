enum DocumentType { genomics, report }

class DocumentModel {
  final String id;
  final String patientId;
  final String fileName;
  final String? filePath;
  final DocumentType type;
  final String mimeType;
  final int? fileSize;
  final DateTime uploadedAt;
  final double uploadProgress;
  final bool isUploaded;

  const DocumentModel({
    required this.id,
    required this.patientId,
    required this.fileName,
    this.filePath,
    required this.type,
    required this.mimeType,
    this.fileSize,
    required this.uploadedAt,
    this.uploadProgress = 1.0,
    this.isUploaded = true,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      filePath: json['file_path']?.toString(),
      type: json['type']?.toString() == 'genomics'
          ? DocumentType.genomics
          : DocumentType.report,
      mimeType: json['mime_type']?.toString() ?? 'application/pdf',
      fileSize: json['file_size'] is int
          ? json['file_size'] as int
          : int.tryParse('${json['file_size'] ?? ''}'),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      uploadProgress: (json['upload_progress'] as num?)?.toDouble() ?? 1.0,
      isUploaded: json['is_uploaded'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'file_name': fileName,
        'file_path': filePath,
        'type': type == DocumentType.genomics ? 'genomics' : 'report',
        'mime_type': mimeType,
        'file_size': fileSize,
        'uploaded_at': uploadedAt.toIso8601String(),
        'upload_progress': uploadProgress,
        'is_uploaded': isUploaded,
      };

  DocumentModel copyWith({
    String? id,
    String? patientId,
    String? fileName,
    String? filePath,
    DocumentType? type,
    String? mimeType,
    int? fileSize,
    DateTime? uploadedAt,
    double? uploadProgress,
    bool? isUploaded,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}
