/// Matches Swagger `PgxResultResponse`.
class PgxResultModel {
  final String id;
  final String gene;
  final String? medicineId;
  final String drugNameRaw;
  final String area;
  final String metabolizerStatus;
  final String clinicalAlert;
  final DateTime? createdAt;

  const PgxResultModel({
    required this.id,
    required this.gene,
    this.medicineId,
    required this.drugNameRaw,
    required this.area,
    required this.metabolizerStatus,
    required this.clinicalAlert,
    this.createdAt,
  });

  factory PgxResultModel.fromJson(Map<String, dynamic> json) {
    return PgxResultModel(
      id: json['id']?.toString() ?? '',
      gene: json['gene']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString(),
      drugNameRaw: json['drug_name_raw']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      metabolizerStatus: json['metabolizer_status']?.toString() ?? '',
      clinicalAlert: json['clinical_alert']?.toString() ?? '',
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
        'created_at': createdAt?.toIso8601String(),
      };

  /// Diplotype / allele call for the panel table.
  /// Prefers `area` when it looks like a genotype; otherwise falls back.
  String get diplotype {
    final a = area.trim();
    if (a.isEmpty) return '—';
    if (_looksLikeDiplotype(a)) return a;
    return a;
  }

  /// Phenotype chip label.
  String get phenotype {
    final status = metabolizerStatus.trim();
    return status.isEmpty ? '—' : status;
  }

  /// CPIC evidence level extracted from clinical alert when present.
  String get cpicLevel {
    final alert = clinicalAlert.trim();
    if (alert.isEmpty) return 'A';

    final levelOnly = RegExp(r'^[A-D]$', caseSensitive: false);
    if (levelOnly.hasMatch(alert)) return alert.toUpperCase();

    final tagged = RegExp(
      r'(?:cpic\s*(?:level)?\s*[:\-]?\s*|level\s+)([A-D])\b',
      caseSensitive: false,
    ).firstMatch(alert);
    if (tagged != null) return tagged.group(1)!.toUpperCase();

    final bare = RegExp(r'\b([A-D])\b').firstMatch(alert);
    if (bare != null && alert.length <= 8) return bare.group(1)!.toUpperCase();

    return 'A';
  }

  String get affectedAgents {
    final drug = drugNameRaw.trim();
    return drug.isEmpty ? '—' : drug;
  }

  static bool _looksLikeDiplotype(String value) {
    return value.contains('*') ||
        value.contains('>') ||
        RegExp(r'rs\d+', caseSensitive: false).hasMatch(value);
  }
}

/// Aggregated panel row for the Genomic Analysis table (one gene call).
class PgxPanelRow {
  final String gene;
  final String diplotype;
  final String phenotype;
  final String cpicLevel;
  final String affectedAgents;
  final List<PgxResultModel> sources;

  const PgxPanelRow({
    required this.gene,
    required this.diplotype,
    required this.phenotype,
    required this.cpicLevel,
    required this.affectedAgents,
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
      final agents = <String>{};
      for (final item in items) {
        final raw = item.drugNameRaw.trim();
        if (raw.isEmpty) continue;
        for (final part in raw.split(RegExp(r'[,;]'))) {
          final name = part.trim();
          if (name.isNotEmpty) agents.add(name);
        }
      }

      return PgxPanelRow(
        gene: first.gene,
        diplotype: first.diplotype,
        phenotype: first.phenotype,
        cpicLevel: first.cpicLevel,
        affectedAgents: agents.isEmpty ? '—' : agents.join(', '),
        sources: List.unmodifiable(items),
      );
    }).toList()
      ..sort((a, b) => a.gene.toLowerCase().compareTo(b.gene.toLowerCase()));
  }
}
