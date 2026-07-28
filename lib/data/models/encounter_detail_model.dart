/// Matches Swagger `EncounterDetailResponse` and nested clinical resources.
class EncounterDetailModel {
  final String id;
  final String patientId;
  final String hospitalId;
  final String visitId;
  final String? encounterType;
  final String? visitClass;
  final String? location;
  final String? attendingProviderName;
  final DateTime? admitDatetime;
  final DateTime? dischargeDatetime;
  final String? patientClass;
  final List<DiagnosisItem> diagnoses;
  final List<ProcedureItem> procedures;
  final List<ObservationItem> observations;
  final List<DiagnosticReportItem> diagnosticReports;
  final List<MedicationOrderItem> medicationOrders;
  final List<MedicationDispenseItem> medicationDispenses;
  final List<ClinicalAlertItem> clinicalAlerts;
  final List<InsuranceItem> insurances;
  final List<EncounterDocumentItem> documents;

  const EncounterDetailModel({
    required this.id,
    required this.patientId,
    required this.hospitalId,
    required this.visitId,
    this.encounterType,
    this.visitClass,
    this.location,
    this.attendingProviderName,
    this.admitDatetime,
    this.dischargeDatetime,
    this.patientClass,
    this.diagnoses = const [],
    this.procedures = const [],
    this.observations = const [],
    this.diagnosticReports = const [],
    this.medicationOrders = const [],
    this.medicationDispenses = const [],
    this.clinicalAlerts = const [],
    this.insurances = const [],
    this.documents = const [],
  });

  bool get isOpen => dischargeDatetime == null;

  factory EncounterDetailModel.fromJson(Map<String, dynamic> json) {
    return EncounterDetailModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      visitId: json['visit_id']?.toString() ?? '',
      encounterType: _nullableString(json['encounter_type']),
      visitClass: _nullableString(json['visit_class']),
      location: _nullableString(json['location']),
      attendingProviderName: _nullableString(json['attending_provider_name']),
      admitDatetime: _parseDateTime(json['admit_datetime']),
      dischargeDatetime: _parseDateTime(json['discharge_datetime']),
      patientClass: _nullableString(json['patient_class']),
      diagnoses: _mapList(json['diagnoses'], DiagnosisItem.fromJson),
      procedures: _mapList(json['procedures'], ProcedureItem.fromJson),
      observations: _mapList(json['observations'], ObservationItem.fromJson),
      diagnosticReports: _mapList(
        json['diagnostic_reports'],
        DiagnosticReportItem.fromJson,
      ),
      medicationOrders: _mapList(
        json['medication_orders'],
        MedicationOrderItem.fromJson,
      ),
      medicationDispenses: _mapList(
        json['medication_dispenses'],
        MedicationDispenseItem.fromJson,
      ),
      clinicalAlerts: _mapList(
        json['clinical_alerts'],
        ClinicalAlertItem.fromJson,
      ),
      insurances: _mapList(json['insurances'], InsuranceItem.fromJson),
      documents: _mapList(json['documents'], EncounterDocumentItem.fromJson),
    );
  }
}

class DiagnosisItem {
  final String id;
  final String code;
  final String codeSystem;
  final String description;
  final String status;
  final DateTime? diagnosisDatetime;

  const DiagnosisItem({
    required this.id,
    required this.code,
    required this.codeSystem,
    required this.description,
    required this.status,
    this.diagnosisDatetime,
  });

  factory DiagnosisItem.fromJson(Map<String, dynamic> json) {
    return DiagnosisItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      codeSystem: json['code_system']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      diagnosisDatetime: _parseDateTime(json['diagnosis_datetime']),
    );
  }
}

class ProcedureItem {
  final String id;
  final String code;
  final String? codeSystem;
  final String description;
  final DateTime? procedureDatetime;
  final String? performingProvider;

  const ProcedureItem({
    required this.id,
    required this.code,
    this.codeSystem,
    required this.description,
    this.procedureDatetime,
    this.performingProvider,
  });

  factory ProcedureItem.fromJson(Map<String, dynamic> json) {
    return ProcedureItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      codeSystem: _nullableString(json['code_system']),
      description: json['description']?.toString() ?? '',
      procedureDatetime: _parseDateTime(json['procedure_datetime']),
      performingProvider: _nullableString(json['performing_provider']),
    );
  }
}

class ObservationItem {
  final String id;
  final String? category;
  final String observationIdentifier;
  final String value;
  final String? units;
  final String? referenceRange;
  final String? abnormalFlag;
  final String resultStatus;
  final DateTime? observationDatetime;

  const ObservationItem({
    required this.id,
    this.category,
    required this.observationIdentifier,
    required this.value,
    this.units,
    this.referenceRange,
    this.abnormalFlag,
    required this.resultStatus,
    this.observationDatetime,
  });

  factory ObservationItem.fromJson(Map<String, dynamic> json) {
    return ObservationItem(
      id: json['id']?.toString() ?? '',
      category: _nullableString(json['category']),
      observationIdentifier: json['observation_identifier']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      units: _nullableString(json['units']),
      referenceRange: _nullableString(json['reference_range']),
      abnormalFlag: _nullableString(json['abnormal_flag']),
      resultStatus: json['result_status']?.toString() ?? '',
      observationDatetime: _parseDateTime(json['observation_datetime']),
    );
  }
}

class DiagnosticReportItem {
  final String id;
  final String reportCode;
  final String? codeSystem;
  final String? category;
  final String? conclusion;
  final String? performerName;
  final DateTime? effectiveDatetime;
  final DateTime? issuedDatetime;

  const DiagnosticReportItem({
    required this.id,
    required this.reportCode,
    this.codeSystem,
    this.category,
    this.conclusion,
    this.performerName,
    this.effectiveDatetime,
    this.issuedDatetime,
  });

  factory DiagnosticReportItem.fromJson(Map<String, dynamic> json) {
    return DiagnosticReportItem(
      id: json['id']?.toString() ?? '',
      reportCode: json['report_code']?.toString() ?? '',
      codeSystem: _nullableString(json['code_system']),
      category: _nullableString(json['category']),
      conclusion: _nullableString(json['conclusion']),
      performerName: _nullableString(json['performer_name']),
      effectiveDatetime: _parseDateTime(json['effective_datetime']),
      issuedDatetime: _parseDateTime(json['issued_datetime']),
    );
  }
}

class MedicationOrderItem {
  final String id;
  final String ndcCode;
  final String drugName;
  final String? dose;
  final String? route;
  final String? quantity;
  final DateTime? orderDatetime;
  final String? orderingProvider;

  const MedicationOrderItem({
    required this.id,
    required this.ndcCode,
    required this.drugName,
    this.dose,
    this.route,
    this.quantity,
    this.orderDatetime,
    this.orderingProvider,
  });

  factory MedicationOrderItem.fromJson(Map<String, dynamic> json) {
    return MedicationOrderItem(
      id: json['id']?.toString() ?? '',
      ndcCode: json['ndc_code']?.toString() ?? '',
      drugName: json['drug_name']?.toString() ?? '',
      dose: _nullableString(json['dose']),
      route: _nullableString(json['route']),
      quantity: _nullableString(json['quantity']),
      orderDatetime: _parseDateTime(json['order_datetime']),
      orderingProvider: _nullableString(json['ordering_provider']),
    );
  }
}

class MedicationDispenseItem {
  final String id;
  final String ndcCode;
  final String drugName;
  final DateTime? dispenseDatetime;
  final String? quantityDispensed;
  final String? dispensingPharmacy;

  const MedicationDispenseItem({
    required this.id,
    required this.ndcCode,
    required this.drugName,
    this.dispenseDatetime,
    this.quantityDispensed,
    this.dispensingPharmacy,
  });

  factory MedicationDispenseItem.fromJson(Map<String, dynamic> json) {
    return MedicationDispenseItem(
      id: json['id']?.toString() ?? '',
      ndcCode: json['ndc_code']?.toString() ?? '',
      drugName: json['drug_name']?.toString() ?? '',
      dispenseDatetime: _parseDateTime(json['dispense_datetime']),
      quantityDispensed: _nullableString(json['quantity_dispensed']),
      dispensingPharmacy: _nullableString(json['dispensing_pharmacy']),
    );
  }
}

class ClinicalAlertItem {
  final String id;
  final String severity;
  final String code;
  final String message;
  final DateTime? raisedDatetime;

  const ClinicalAlertItem({
    required this.id,
    required this.severity,
    required this.code,
    required this.message,
    this.raisedDatetime,
  });

  factory ClinicalAlertItem.fromJson(Map<String, dynamic> json) {
    return ClinicalAlertItem(
      id: json['id']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      raisedDatetime: _parseDateTime(json['raised_datetime']),
    );
  }
}

class InsuranceItem {
  final String id;
  final String payerName;
  final String? planId;
  final String? policyNumber;
  final String? memberId;
  final String? subscriberName;
  final String? relationship;

  const InsuranceItem({
    required this.id,
    required this.payerName,
    this.planId,
    this.policyNumber,
    this.memberId,
    this.subscriberName,
    this.relationship,
  });

  factory InsuranceItem.fromJson(Map<String, dynamic> json) {
    return InsuranceItem(
      id: json['id']?.toString() ?? '',
      payerName: json['payer_name']?.toString() ?? '',
      planId: _nullableString(json['plan_id']),
      policyNumber: _nullableString(json['policy_number']),
      memberId: _nullableString(json['member_id']),
      subscriberName: _nullableString(json['subscriber_name']),
      relationship: _nullableString(json['relationship']),
    );
  }
}

class EncounterDocumentItem {
  final String id;
  final String patientId;
  final String? encounterId;
  final String? title;
  final String? mimeType;
  final String? fileUrl;
  final DateTime? createdAt;

  const EncounterDocumentItem({
    required this.id,
    required this.patientId,
    this.encounterId,
    this.title,
    this.mimeType,
    this.fileUrl,
    this.createdAt,
  });

  factory EncounterDocumentItem.fromJson(Map<String, dynamic> json) {
    return EncounterDocumentItem(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      encounterId: _nullableString(json['encounter_id']),
      title: _nullableString(json['title']),
      mimeType: _nullableString(json['mime_type']),
      fileUrl: _nullableString(json['file_url']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

List<T> _mapList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) mapper,
) {
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map>()
      .map((e) => mapper(Map<String, dynamic>.from(e)))
      .toList();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
