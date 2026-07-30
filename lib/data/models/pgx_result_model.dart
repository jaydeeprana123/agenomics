/// Nested clinical alert payload under an affected drug.
/// Only `recommendation_text` is surfaced in the UI.
class PgxDrugClinicalAlert {
  final String? recommendationText;

  const PgxDrugClinicalAlert({this.recommendationText});

  factory PgxDrugClinicalAlert.fromJson(Map<String, dynamic> json) {
    return PgxDrugClinicalAlert(
      recommendationText: _nullableString(json['recommendation_text']),
    );
  }

  Map<String, dynamic> toJson() => {
        'recommendation_text': recommendationText,
      };
}

/// One entry from `affected_drugs` (`AffectedDrugAlert`).
class PgxAffectedDrug {
  final String? drug;
  final PgxDrugClinicalAlert? clinicalAlert;

  const PgxAffectedDrug({
    this.drug,
    this.clinicalAlert,
  });

  factory PgxAffectedDrug.fromJson(dynamic raw) {
    if (raw is String) {
      return PgxAffectedDrug(drug: _nullableString(raw));
    }
    if (raw is! Map) {
      return const PgxAffectedDrug();
    }

    final json = Map<String, dynamic>.from(raw);
    PgxDrugClinicalAlert? alert;
    final alertRaw = json['clinical_alert'];
    if (alertRaw is Map) {
      alert = PgxDrugClinicalAlert.fromJson(
        Map<String, dynamic>.from(alertRaw),
      );
    }

    return PgxAffectedDrug(
      drug: _nullableString(json['drug']),
      clinicalAlert: alert,
    );
  }

  Map<String, dynamic> toJson() => {
        'drug': drug,
        'clinical_alert': clinicalAlert?.toJson(),
      };

  String? get recommendationText => clinicalAlert?.recommendationText;

  /// Whether this entry has anything meaningful to render.
  bool get hasDisplayContent {
    final name = drug?.trim() ?? '';
    final recommendation = recommendationText?.trim() ?? '';
    return name.isNotEmpty || recommendation.isNotEmpty;
  }
}

/// Matches Swagger `PgxResultResponse`.
class PgxResultModel {
  final String id;
  final String gene;
  final String? medicineId;
  final String? drugNameRaw;
  final String? area;
  final String? metabolizerStatus;
  final String? clinicalAlert;
  final String? diplotypeRaw;
  final String? phenotypeRaw;
  final double? activityScore;
  final String? cpicLevelRaw;
  final List<PgxAffectedDrug> affectedDrugs;
  final String? dataSource;
  final double? confidence;
  final bool? pharmcatProcessed;
  final String? reportDate;
  final String? performingLab;
  final String? genomikiJobId;
  final DateTime? createdAt;

  const PgxResultModel({
    required this.id,
    required this.gene,
    this.medicineId,
    this.drugNameRaw,
    this.area,
    this.metabolizerStatus,
    this.clinicalAlert,
    this.diplotypeRaw,
    this.phenotypeRaw,
    this.activityScore,
    this.cpicLevelRaw,
    this.affectedDrugs = const [],
    this.dataSource,
    this.confidence,
    this.pharmcatProcessed,
    this.reportDate,
    this.performingLab,
    this.genomikiJobId,
    this.createdAt,
  });

  factory PgxResultModel.fromJson(Map<String, dynamic> json) {
    return PgxResultModel(
      id: json['id']?.toString() ?? '',
      gene: json['gene']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString(),
      drugNameRaw: _nullableString(json['drug_name_raw']),
      area: _nullableString(json['area']),
      metabolizerStatus: _nullableString(json['metabolizer_status']),
      clinicalAlert: _nullableString(json['clinical_alert']),
      diplotypeRaw: _nullableString(json['diplotype']),
      phenotypeRaw: _nullableString(json['phenotype']),
      activityScore: _nullableDouble(json['activity_score']),
      cpicLevelRaw: _nullableString(json['cpic_level']),
      affectedDrugs: _parseAffectedDrugs(json['affected_drugs']),
      dataSource: _nullableString(json['data_source']),
      confidence: _nullableDouble(json['confidence']),
      pharmcatProcessed: json['pharmcat_processed'] is bool
          ? json['pharmcat_processed'] as bool
          : null,
      reportDate: _nullableString(json['report_date']),
      performingLab: _nullableString(json['performing_lab']),
      genomikiJobId: _nullableString(json['genomiki_job_id']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gene': gene,
        'medicine_id': medicineId,
        'drug_name_raw': drugNameRaw,
        'area': area,
        'metabolizer_status': metabolizerStatus,
        'clinical_alert': clinicalAlert,
        'diplotype': diplotypeRaw,
        'phenotype': phenotypeRaw,
        'activity_score': activityScore,
        'cpic_level': cpicLevelRaw,
        'affected_drugs': affectedDrugs.map((e) => e.toJson()).toList(),
        'data_source': dataSource,
        'confidence': confidence,
        'pharmcat_processed': pharmcatProcessed,
        'report_date': reportDate,
        'performing_lab': performingLab,
        'genomiki_job_id': genomikiJobId,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Diplotype / allele call for the panel table.
  String get diplotype {
    final d = diplotypeRaw?.trim();
    if (d != null && d.isNotEmpty) return d;
    final a = area?.trim();
    if (a != null && a.isNotEmpty) return a;
    return '—';
  }

  /// Phenotype chip label.
  String get phenotype {
    final status = metabolizerStatus?.trim();
    if (status != null && status.isNotEmpty) return status;

    final raw = phenotypeRaw?.trim();
    if (raw == null || raw.isEmpty) return '—';
    return raw
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// CPIC evidence level.
  String get cpicLevel {
    final level = cpicLevelRaw?.trim();
    if (level != null && level.isNotEmpty) {
      final match = RegExp(r'[A-D]', caseSensitive: false).firstMatch(level);
      if (match != null) return match.group(0)!.toUpperCase();
      return level.toUpperCase();
    }

    final alert = clinicalAlert?.trim() ?? '';
    if (alert.isEmpty) return '—';

    final levelOnly = RegExp(r'^[A-D]$', caseSensitive: false);
    if (levelOnly.hasMatch(alert)) return alert.toUpperCase();

    final tagged = RegExp(
      r'(?:cpic\s*(?:level)?\s*[:\-]?\s*|level\s+)([A-D])\b',
      caseSensitive: false,
    ).firstMatch(alert);
    if (tagged != null) return tagged.group(1)!.toUpperCase();

    return '—';
  }

  static List<PgxAffectedDrug> _parseAffectedDrugs(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(PgxAffectedDrug.fromJson)
        .where((e) => e.hasDisplayContent)
        .toList();
  }
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null' || text.toLowerCase() == 'n/a') {
    return null;
  }
  return text;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Aggregated panel row for the Genomic Analysis table (one gene call).
class PgxPanelRow {
  final String gene;
  final String diplotype;
  final String phenotype;
  final String cpicLevel;
  final List<PgxAffectedDrug> affectedDrugs;
  final List<PgxResultModel> sources;

  const PgxPanelRow({
    required this.gene,
    required this.diplotype,
    required this.phenotype,
    required this.cpicLevel,
    this.affectedDrugs = const [],
    required this.sources,
  });

  static List<PgxPanelRow> fromResults(List<PgxResultModel> results) {
    final grouped = <String, List<PgxResultModel>>{};
    for (final result in results) {
      final key = [
        result.gene.trim().toUpperCase(),
        result.diplotype,
        result.phenotype.toLowerCase(),
      ].join('|');
      grouped.putIfAbsent(key, () => []).add(result);
    }

    return grouped.values.map((items) {
      final first = items.first;
      final drugs = <PgxAffectedDrug>[];
      final seen = <String>{};

      for (final item in items) {
        for (final drug in item.affectedDrugs) {
          if (!drug.hasDisplayContent) continue;
          final key = (drug.drug ?? drug.recommendationText ?? '')
              .trim()
              .toLowerCase();
          if (key.isEmpty || !seen.add(key)) continue;
          drugs.add(drug);
        }

        // Legacy fallback: plain drug_name_raw string list.
        final raw = item.drugNameRaw?.trim() ?? '';
        if (raw.isEmpty) continue;
        for (final part in raw.split(RegExp(r'[,;]'))) {
          final name = _nullableString(part);
          if (name == null) continue;
          final key = name.toLowerCase();
          if (!seen.add(key)) continue;
          drugs.add(PgxAffectedDrug(drug: name));
        }
      }

      return PgxPanelRow(
        gene: first.gene,
        diplotype: first.diplotype,
        phenotype: first.phenotype,
        cpicLevel: first.cpicLevel,
        affectedDrugs: drugs,
        sources: List.unmodifiable(items),
      );
    }).toList()
      ..sort((a, b) => a.gene.toLowerCase().compareTo(b.gene.toLowerCase()));
  }
}
