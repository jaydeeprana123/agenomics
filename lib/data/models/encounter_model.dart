/// Matches Swagger `EncounterResponse`.
class EncounterModel {
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

  const EncounterModel({
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
  });

  /// Short label for header chips and lists.
  String get displayLabel {
    if (visitId.trim().isNotEmpty) return visitId.trim();
    if (encounterType != null && encounterType!.trim().isNotEmpty) {
      return encounterType!.trim();
    }
    return id;
  }

  String get displayMeta {
    final parts = <String>[
      if (encounterType != null && encounterType!.trim().isNotEmpty)
        encounterType!.trim(),
      if (visitClass != null && visitClass!.trim().isNotEmpty)
        visitClass!.trim(),
      if (location != null && location!.trim().isNotEmpty) location!.trim(),
    ];
    return parts.join(' · ');
  }

  bool get isOpen => dischargeDatetime == null;

  factory EncounterModel.fromJson(Map<String, dynamic> json) {
    return EncounterModel(
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'hospital_id': hospitalId,
        'visit_id': visitId,
        'encounter_type': encounterType,
        'visit_class': visitClass,
        'location': location,
        'attending_provider_name': attendingProviderName,
        'admit_datetime': admitDatetime?.toIso8601String(),
        'discharge_datetime': dischargeDatetime?.toIso8601String(),
        'patient_class': patientClass,
      };

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
