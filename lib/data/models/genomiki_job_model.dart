/// Matches Swagger `GenomikiJobOut`.
class GenomikiJobModel {
  final String id;
  final String hospitalId;
  final String? submittedByUserId;
  final String sourceFormat;
  final String? sourceFilename;
  final String? sampleId;
  final String? jobId;
  final String submitStatus;
  final String? statusUrl;
  final String? errorMessage;
  final DateTime? submittedAt;
  final DateTime? lastCheckedAt;
  final DateTime? completedAt;

  const GenomikiJobModel({
    required this.id,
    required this.hospitalId,
    this.submittedByUserId,
    required this.sourceFormat,
    this.sourceFilename,
    this.sampleId,
    this.jobId,
    required this.submitStatus,
    this.statusUrl,
    this.errorMessage,
    this.submittedAt,
    this.lastCheckedAt,
    this.completedAt,
  });

  factory GenomikiJobModel.fromJson(Map<String, dynamic> json) {
    return GenomikiJobModel(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      submittedByUserId: json['submitted_by_user_id']?.toString(),
      sourceFormat: json['source_format']?.toString() ?? '',
      sourceFilename: json['source_filename']?.toString(),
      sampleId: json['sample_id']?.toString(),
      jobId: json['job_id']?.toString(),
      submitStatus: json['submit_status']?.toString() ?? '',
      statusUrl: json['status_url']?.toString(),
      errorMessage: json['error_message']?.toString(),
      submittedAt: _parseDate(json['submitted_at']),
      lastCheckedAt: _parseDate(json['last_checked_at']),
      completedAt: _parseDate(json['completed_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hospital_id': hospitalId,
        'submitted_by_user_id': submittedByUserId,
        'source_format': sourceFormat,
        'source_filename': sourceFilename,
        'sample_id': sampleId,
        'job_id': jobId,
        'submit_status': submitStatus,
        'status_url': statusUrl,
        'error_message': errorMessage,
        'submitted_at': submittedAt?.toIso8601String(),
        'last_checked_at': lastCheckedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  String get displayJobId =>
      (jobId != null && jobId!.isNotEmpty) ? jobId! : id;

  String get displayFilename =>
      (sourceFilename != null && sourceFilename!.trim().isNotEmpty)
          ? sourceFilename!.trim()
          : '—';

  String get displaySampleId =>
      (sampleId != null && sampleId!.trim().isNotEmpty)
          ? sampleId!.trim()
          : '—';

  bool get isTerminal {
    final s = submitStatus.toLowerCase();
    return s == 'complete' || s == 'failed' || s == 'error';
  }

  bool get isInProgress {
    final s = submitStatus.toLowerCase();
    return s == 'queued' || s == 'running';
  }

  GenomikiJobModel copyWith({
    String? submitStatus,
    String? errorMessage,
    DateTime? lastCheckedAt,
    DateTime? completedAt,
  }) {
    return GenomikiJobModel(
      id: id,
      hospitalId: hospitalId,
      submittedByUserId: submittedByUserId,
      sourceFormat: sourceFormat,
      sourceFilename: sourceFilename,
      sampleId: sampleId,
      jobId: jobId,
      submitStatus: submitStatus ?? this.submitStatus,
      statusUrl: statusUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedAt: submittedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

/// Matches Swagger `LiveStatusOut`.
class GenomikiLiveStatusModel {
  final String jobId;
  final String genomikiStatus;
  final GenomikiJobModel? dbRecord;

  const GenomikiLiveStatusModel({
    required this.jobId,
    required this.genomikiStatus,
    this.dbRecord,
  });

  factory GenomikiLiveStatusModel.fromJson(Map<String, dynamic> json) {
    GenomikiJobModel? record;
    final raw = json['db_record'];
    if (raw is Map) {
      record = GenomikiJobModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return GenomikiLiveStatusModel(
      jobId: json['job_id']?.toString() ?? '',
      genomikiStatus: json['genomiki_status']?.toString() ?? '',
      dbRecord: record,
    );
  }
}
