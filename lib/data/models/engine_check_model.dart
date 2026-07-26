/// Flexible clinical alert from engine-check arrays (free-form objects).
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
  });

  factory EngineAlert.fromJson(String category, Map<String, dynamic> json) {
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return null;
    }

    final reaction = pick(const [
      'reaction',
      'title',
      'alert',
      'code',
      'gene',
      'interaction',
      'phenotype',
    ]);
    final message = pick(const [
      'message',
      'description',
      'guidance',
      'clinical_guidance',
      'detail',
      'summary',
    ]);
    final recommendation = pick(const [
      'prevention_recommendation',
      'recommendation',
      'action',
      'guidance',
      'clinical_guidance',
    ]);

    return EngineAlert(
      category: category,
      raw: json,
      medicineId: pick(const ['medicine_id', 'drug_id', 'med_id']),
      title: reaction,
      message: message ?? recommendation,
      severity: pick(const ['severity', 'level', 'priority', 'risk']),
      recommendation: recommendation,
      riskFactor: pick(const ['risk_factor', 'factor', 'trigger']),
      onset: pick(const ['onset']),
      monitoring: pick(const ['monitoring_parameter', 'monitoring']),
    );
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (message != null && message!.isNotEmpty) return message!;
    return categoryLabel;
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
        s.contains('contraindic');
  }

  bool get isWarning {
    final s = (severity ?? '').toLowerCase();
    return s.contains('moderate') ||
        s.contains('warn') ||
        s.contains('medium') ||
        s.contains('intermediate');
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

  List<EngineAlert> get allAlerts => [
        ...pgxAlerts,
        ...ddiAlerts,
        ...adrAlerts,
        ...oncologyEligibility,
      ];

  int get activeCount => allAlerts.length;

  bool get isEmpty => activeCount == 0;
}
