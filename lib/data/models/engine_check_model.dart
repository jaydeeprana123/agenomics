/// Structured CPIC/PharmGKB clinical alert payload nested under PGx alerts.
/// Matches Swagger `ClinicalAlertPayload`. All fields nullable for safe parsing.
class EngineClinicalAlert {
  final String? recommendationText;
  final String? classification;
  final String? source;
  final String? guidelineVersion;
  final String? guidelineName;
  final String? citationUrl;
  final String? population;
  final String? publicationDate;
  final String? lastSyncedAt;
  final String? comments;
  final String? disclaimer;

  const EngineClinicalAlert({
    this.recommendationText,
    this.classification,
    this.source,
    this.guidelineVersion,
    this.guidelineName,
    this.citationUrl,
    this.population,
    this.publicationDate,
    this.lastSyncedAt,
    this.comments,
    this.disclaimer,
  });

  factory EngineClinicalAlert.fromJson(Map<String, dynamic> json) {
    return EngineClinicalAlert(
      recommendationText: _nullableString(json['recommendation_text']),
      classification: _nullableString(json['classification']),
      source: _nullableString(json['source']),
      guidelineVersion: _nullableString(json['guideline_version']),
      guidelineName: _nullableString(json['guideline_name']),
      citationUrl: _nullableString(json['citation_url']),
      population: _nullableString(json['population']),
      publicationDate: _nullableString(json['publication_date']),
      lastSyncedAt: _nullableString(json['last_synced_at']),
      comments: _nullableString(json['comments']),
      disclaimer: _nullableString(json['disclaimer']),
    );
  }

  Map<String, dynamic> toJson() => {
        'recommendation_text': recommendationText,
        'classification': classification,
        'source': source,
        'guideline_version': guidelineVersion,
        'guideline_name': guidelineName,
        'citation_url': citationUrl,
        'population': population,
        'publication_date': publicationDate,
        'last_synced_at': lastSyncedAt,
        'comments': comments,
        'disclaimer': disclaimer,
      };

  bool get hasContent =>
      recommendationText != null ||
      classification != null ||
      source != null ||
      guidelineName != null ||
      guidelineVersion != null ||
      citationUrl != null ||
      population != null ||
      publicationDate != null ||
      lastSyncedAt != null ||
      comments != null ||
      disclaimer != null;
}

/// Flexible clinical alert from engine-check arrays (free-form objects).
/// Supports legacy flat ADR/DDI shapes and the newer PGx / oncology payloads.
class EngineAlert {
  final String category;
  final Map<String, dynamic> raw;
  final String? medicineId;
  final String? title;
  final String? message;
  final String? severity;
  final String? recommendation;
  final String? riskFactor;
  final String? onset;
  final String? monitoring;

  // PGx-specific (new response shape when medicine_ids are provided)
  final String? gene;
  final String? drugNameRaw;
  final String? area;
  final String? metabolizerStatus;
  final String? phenotype;
  final String? diplotype;
  final EngineClinicalAlert? clinicalAlert;
  final String? clinicalAlertText;
  final String? alertStatus;
  final String? reason;

  // Oncology eligibility
  final String? biomarkerType;
  final String? patientValue;
  final String? patientStatus;
  final String? requiredStatus;
  final bool? eligible;

  const EngineAlert({
    required this.category,
    required this.raw,
    this.medicineId,
    this.title,
    this.message,
    this.severity,
    this.recommendation,
    this.riskFactor,
    this.onset,
    this.monitoring,
    this.gene,
    this.drugNameRaw,
    this.area,
    this.metabolizerStatus,
    this.phenotype,
    this.diplotype,
    this.clinicalAlert,
    this.clinicalAlertText,
    this.alertStatus,
    this.reason,
    this.biomarkerType,
    this.patientValue,
    this.patientStatus,
    this.requiredStatus,
    this.eligible,
  });

  factory EngineAlert.fromJson(String category, Map<String, dynamic> json) {
    EngineClinicalAlert? nestedAlert;
    String? alertText;
    final clinicalRaw = json['clinical_alert'];
    if (clinicalRaw is Map) {
      nestedAlert = EngineClinicalAlert.fromJson(
        Map<String, dynamic>.from(clinicalRaw),
      );
    } else {
      alertText = _nullableString(clinicalRaw);
    }

    final reaction = _pick(json, const [
      'reaction',
      'title',
      'alert',
      'code',
      'interaction',
      'biomarker_type',
    ]);
    final gene = _nullableString(json['gene']);
    final drugName = _nullableString(json['drug_name_raw']);

    final message = _pick(json, const [
      'message',
      'description',
      'guidance',
      'clinical_guidance',
      'detail',
      'summary',
    ]);

    final recommendation = _pick(json, const [
      'prevention_recommendation',
      'recommendation',
      'action',
      'guidance',
      'clinical_guidance',
    ]);

    final nestedRecommendation = nestedAlert?.recommendationText;
    final resolvedMessage = message ??
        nestedRecommendation ??
        alertText ??
        recommendation;
    final resolvedRecommendation =
        recommendation ?? nestedRecommendation ?? alertText;

    final title = reaction ??
        (gene != null && drugName != null
            ? '$gene · $drugName'
            : gene ?? drugName);

    final severity = _pick(json, const [
          'severity',
          'level',
          'priority',
          'risk',
        ]) ??
        nestedAlert?.classification;

    return EngineAlert(
      category: category,
      raw: json,
      medicineId: _pick(json, const ['medicine_id', 'drug_id', 'med_id']),
      title: title,
      message: resolvedMessage,
      severity: severity,
      recommendation: resolvedRecommendation,
      riskFactor: _pick(json, const ['risk_factor', 'factor', 'trigger']),
      onset: _nullableString(json['onset']),
      monitoring:
          _pick(json, const ['monitoring_parameter', 'monitoring']),
      gene: gene,
      drugNameRaw: drugName,
      area: _nullableString(json['area']),
      metabolizerStatus: _nullableString(json['metabolizer_status']),
      phenotype: _nullableString(json['phenotype']),
      diplotype: _nullableString(json['diplotype']),
      clinicalAlert: nestedAlert,
      clinicalAlertText: alertText,
      alertStatus: _nullableString(json['alert_status']),
      reason: _nullableString(json['reason']),
      biomarkerType: _nullableString(json['biomarker_type']),
      patientValue: _nullableString(json['patient_value']),
      patientStatus: _nullableString(json['patient_status']),
      requiredStatus: _nullableString(json['required_status']),
      eligible: json['eligible'] is bool ? json['eligible'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (message != null && message!.isNotEmpty) return message!;
    return categoryLabel;
  }

  /// Prefer selected-medicine name, then API drug_name_raw.
  String resolvedMedicineName(String? selectedName) {
    final selected = selectedName?.trim() ?? '';
    if (selected.isNotEmpty) return selected;
    return drugNameRaw ?? '';
  }

  String get categoryLabel {
    switch (category) {
      case 'pgx':
        return 'PGx Alert';
      case 'ddi':
        return 'Drug Interaction';
      case 'adr':
        return 'ADR Alert';
      case 'oncology':
        return 'Oncology Eligibility';
      default:
        return 'Clinical Alert';
    }
  }

  String get hookLabel {
    switch (category) {
      case 'pgx':
        return 'medication-prescribe';
      case 'ddi':
        return 'drug-drug-interaction';
      case 'adr':
        return 'adverse-reaction';
      case 'oncology':
        return 'oncology-eligibility';
      default:
        return category;
    }
  }

  bool get isCritical {
    final s = (severity ?? '').toLowerCase();
    return s.contains('life') ||
        s.contains('critical') ||
        s.contains('severe') ||
        s.contains('high') ||
        s.contains('contraindic') ||
        eligible == false;
  }

  bool get isWarning {
    final s = (severity ?? '').toLowerCase();
    return s.contains('moderate') ||
        s.contains('warn') ||
        s.contains('medium') ||
        s.contains('intermediate') ||
        s.contains('flag');
  }
}

/// Matches Swagger `EngineCheckResponse`.
class EngineCheckResponse {
  final List<EngineAlert> pgxAlerts;
  final List<EngineAlert> ddiAlerts;
  final List<EngineAlert> adrAlerts;
  final List<EngineAlert> oncologyEligibility;

  const EngineCheckResponse({
    this.pgxAlerts = const [],
    this.ddiAlerts = const [],
    this.adrAlerts = const [],
    this.oncologyEligibility = const [],
  });

  factory EngineCheckResponse.fromJson(Map<String, dynamic> json) {
    List<EngineAlert> parse(String key, String category) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => EngineAlert.fromJson(
                category,
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return EngineCheckResponse(
      pgxAlerts: parse('pgx_alerts', 'pgx'),
      ddiAlerts: parse('ddi_alerts', 'ddi'),
      adrAlerts: parse('adr_alerts', 'adr'),
      oncologyEligibility: parse('oncology_eligibility', 'oncology'),
    );
  }

  Map<String, dynamic> toJson() => {
        'pgx_alerts': pgxAlerts.map((e) => e.toJson()).toList(),
        'ddi_alerts': ddiAlerts.map((e) => e.toJson()).toList(),
        'adr_alerts': adrAlerts.map((e) => e.toJson()).toList(),
        'oncology_eligibility':
            oncologyEligibility.map((e) => e.toJson()).toList(),
      };

  List<EngineAlert> get allAlerts => [
        ...pgxAlerts,
        ...ddiAlerts,
        ...adrAlerts,
        ...oncologyEligibility,
      ];

  int get activeCount => allAlerts.length;

  bool get isEmpty => activeCount == 0;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty ||
      text.toLowerCase() == 'null' ||
      text.toLowerCase() == 'n/a') {
    return null;
  }
  return text;
}

String? _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _nullableString(json[key]);
    if (value != null) return value;
  }
  return null;
}
