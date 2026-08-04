import 'package:cloud_firestore/cloud_firestore.dart';

/// Consent request lifecycle statuses.
abstract class ConsentStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String declined = 'declined';
}

/// Individual genomic processing purposes (toggle independently).
class ConsentPurposes {
  final bool identityVerification;
  final bool hieRecordRetrieval;
  final bool pharmacogenomicProcessing;
  final bool germlineInterpretation;
  final bool claimEvidenceAttachment;
  final bool secondaryResearchUse;
  final bool familyCascadeDisclosure;

  const ConsentPurposes({
    this.identityVerification = true,
    this.hieRecordRetrieval = true,
    this.pharmacogenomicProcessing = true,
    this.germlineInterpretation = true,
    this.claimEvidenceAttachment = true,
    this.secondaryResearchUse = false,
    this.familyCascadeDisclosure = false,
  });

  factory ConsentPurposes.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ConsentPurposes();
    return ConsentPurposes(
      identityVerification: json['identityVerification'] != false,
      hieRecordRetrieval: json['hieRecordRetrieval'] != false,
      pharmacogenomicProcessing: json['pharmacogenomicProcessing'] != false,
      germlineInterpretation: json['germlineInterpretation'] != false,
      claimEvidenceAttachment: json['claimEvidenceAttachment'] != false,
      secondaryResearchUse: json['secondaryResearchUse'] == true,
      familyCascadeDisclosure: json['familyCascadeDisclosure'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'identityVerification': identityVerification,
        'hieRecordRetrieval': hieRecordRetrieval,
        'pharmacogenomicProcessing': pharmacogenomicProcessing,
        'germlineInterpretation': germlineInterpretation,
        'claimEvidenceAttachment': claimEvidenceAttachment,
        'secondaryResearchUse': secondaryResearchUse,
        'familyCascadeDisclosure': familyCascadeDisclosure,
      };

  ConsentPurposes copyWith({
    bool? identityVerification,
    bool? hieRecordRetrieval,
    bool? pharmacogenomicProcessing,
    bool? germlineInterpretation,
    bool? claimEvidenceAttachment,
    bool? secondaryResearchUse,
    bool? familyCascadeDisclosure,
  }) {
    return ConsentPurposes(
      identityVerification: identityVerification ?? this.identityVerification,
      hieRecordRetrieval: hieRecordRetrieval ?? this.hieRecordRetrieval,
      pharmacogenomicProcessing:
          pharmacogenomicProcessing ?? this.pharmacogenomicProcessing,
      germlineInterpretation:
          germlineInterpretation ?? this.germlineInterpretation,
      claimEvidenceAttachment:
          claimEvidenceAttachment ?? this.claimEvidenceAttachment,
      secondaryResearchUse: secondaryResearchUse ?? this.secondaryResearchUse,
      familyCascadeDisclosure:
          familyCascadeDisclosure ?? this.familyCascadeDisclosure,
    );
  }

  /// All optional research / family purposes off; clinical defaults on.
  ConsentPurposes get declinedAll => const ConsentPurposes(
        identityVerification: false,
        hieRecordRetrieval: false,
        pharmacogenomicProcessing: false,
        germlineInterpretation: false,
        claimEvidenceAttachment: false,
        secondaryResearchUse: false,
        familyCascadeDisclosure: false,
      );
}

/// Firestore document for a genomic processing consent request.
class ConsentRequestModel {
  final String id;
  final String patientId;
  final String patientUhid;
  final String patientName;
  final String? emiratesId;
  final String hospitalId;
  final String hospitalName;
  final String hospitalRef;
  final String patientRef;
  final String status;
  final ConsentPurposes purposes;
  final String? patientSignatureUrl;
  final String? clinicianSignatureUrl;
  final String? clinicianName;
  final String source;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const ConsentRequestModel({
    required this.id,
    required this.patientId,
    required this.patientUhid,
    required this.patientName,
    this.emiratesId,
    required this.hospitalId,
    this.hospitalName = 'Aster Hospital, Abu Dhabi',
    this.hospitalRef = 'AUH-HFR-00512',
    required this.patientRef,
    this.status = ConsentStatus.pending,
    this.purposes = const ConsentPurposes(),
    this.patientSignatureUrl,
    this.clinicianSignatureUrl,
    this.clinicianName,
    this.source = 'desktop',
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  bool get isPending => status == ConsentStatus.pending;
  bool get isApproved => status == ConsentStatus.approved;
  bool get isDeclined => status == ConsentStatus.declined;

  factory ConsentRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ConsentRequestModel.fromJson(data, id: doc.id);
  }

  factory ConsentRequestModel.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    Map<String, dynamic>? purposesMap;
    final rawPurposes = json['purposes'];
    if (rawPurposes is Map) {
      purposesMap = Map<String, dynamic>.from(rawPurposes);
    }

    return ConsentRequestModel(
      id: id ?? json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientUhid: json['patientUhid']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      emiratesId: json['emiratesId']?.toString(),
      hospitalId: json['hospitalId']?.toString() ?? '',
      hospitalName:
          json['hospitalName']?.toString() ?? 'Aster Hospital, Abu Dhabi',
      hospitalRef: json['hospitalRef']?.toString() ?? 'AUH-HFR-00512',
      patientRef: json['patientRef']?.toString() ?? '',
      status: json['status']?.toString() ?? ConsentStatus.pending,
      purposes: ConsentPurposes.fromJson(purposesMap),
      patientSignatureUrl: json['patientSignatureUrl']?.toString(),
      clinicianSignatureUrl: json['clinicianSignatureUrl']?.toString(),
      clinicianName: json['clinicianName']?.toString(),
      source: json['source']?.toString() ?? 'desktop',
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      completedAt: _toDate(json['completedAt']),
    );
  }

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    final map = <String, dynamic>{
      'patientId': patientId,
      'patientUhid': patientUhid,
      'patientName': patientName,
      'emiratesId': emiratesId,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'hospitalRef': hospitalRef,
      'patientRef': patientRef,
      'status': status,
      'purposes': purposes.toJson(),
      'patientSignatureUrl': patientSignatureUrl,
      'clinicianSignatureUrl': clinicianSignatureUrl,
      'clinicianName': clinicianName,
      'source': source,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isCreate) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }
    if (completedAt != null ||
        status == ConsentStatus.approved ||
        status == ConsentStatus.declined) {
      map['completedAt'] = FieldValue.serverTimestamp();
    }
    return map;
  }

  ConsentRequestModel copyWith({
    String? id,
    String? patientId,
    String? patientUhid,
    String? patientName,
    String? emiratesId,
    String? hospitalId,
    String? hospitalName,
    String? hospitalRef,
    String? patientRef,
    String? status,
    ConsentPurposes? purposes,
    String? patientSignatureUrl,
    String? clinicianSignatureUrl,
    String? clinicianName,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return ConsentRequestModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientUhid: patientUhid ?? this.patientUhid,
      patientName: patientName ?? this.patientName,
      emiratesId: emiratesId ?? this.emiratesId,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalRef: hospitalRef ?? this.hospitalRef,
      patientRef: patientRef ?? this.patientRef,
      status: status ?? this.status,
      purposes: purposes ?? this.purposes,
      patientSignatureUrl: patientSignatureUrl ?? this.patientSignatureUrl,
      clinicianSignatureUrl:
          clinicianSignatureUrl ?? this.clinicianSignatureUrl,
      clinicianName: clinicianName ?? this.clinicianName,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

/// Purpose row metadata for the consent form UI (EN + AR).
class ConsentPurposeItem {
  final String key;
  final String titleEn;
  final String descriptionEn;
  final String titleAr;
  final bool required;
  final bool defaultOn;

  const ConsentPurposeItem({
    required this.key,
    required this.titleEn,
    required this.descriptionEn,
    required this.titleAr,
    this.required = false,
    this.defaultOn = true,
  });

  static const List<ConsentPurposeItem> all = [
    ConsentPurposeItem(
      key: 'identityVerification',
      titleEn: 'Identity verification',
      descriptionEn:
          'Assert who the patient is via UAE Pass / EIDA. Always required.',
      titleAr: 'التحقق من الهوية',
      required: true,
      defaultOn: true,
    ),
    ConsentPurposeItem(
      key: 'hieRecordRetrieval',
      titleEn: 'HIE record retrieval',
      descriptionEn:
          'Query Malaffi / NABIDH / Riayati for existing clinical records.',
      titleAr: 'الاطلاع على السجل الصحي',
      defaultOn: true,
    ),
    ConsentPurposeItem(
      key: 'pharmacogenomicProcessing',
      titleEn: 'Pharmacogenomic processing',
      descriptionEn: 'Derive drug-metabolism phenotypes and run CPIC rules.',
      titleAr: 'تحليل الاستجابة الدوائية الجينية',
      defaultOn: true,
    ),
    ConsentPurposeItem(
      key: 'germlineInterpretation',
      titleEn: 'Germline interpretation',
      descriptionEn:
          'Interpret hereditary cancer variants (BRCA1/2, Lynch, HRR).',
      titleAr: 'تفسير المتغيرات الوراثية',
      defaultOn: true,
    ),
    ConsentPurposeItem(
      key: 'claimEvidenceAttachment',
      titleEn: 'Claim evidence attachment',
      descriptionEn:
          'Attach genomic results to the payer claim as medical-necessity evidence.',
      titleAr: 'إرفاق الأدلة بالمطالبة التأمينية',
      defaultOn: true,
    ),
    ConsentPurposeItem(
      key: 'secondaryResearchUse',
      titleEn: 'Secondary research use',
      descriptionEn:
          'De-identified contribution to the federated model. Separate, explicit, default OFF.',
      titleAr: 'الاستخدام البحثي لبيانات مجهولة الهوية',
      defaultOn: false,
    ),
    ConsentPurposeItem(
      key: 'familyCascadeDisclosure',
      titleEn: 'Family cascade disclosure',
      descriptionEn:
          'Permit disclosure of actionable germline findings to named relatives.',
      titleAr: 'إبلاغ الأقارب بالنتائج',
      defaultOn: false,
    ),
  ];
}
