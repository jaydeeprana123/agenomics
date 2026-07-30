import 'dart:convert';

import 'package:agenomics/data/models/engine_check_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses nested PGx clinical_alert + ADR alerts', () {
    const raw = r'''
{
  "pgx_alerts":[{
    "medicine_id":"e9854365-ebb3-4582-951f-9687c27d8d6c",
    "gene":"CYP2C19",
    "drug_name_raw":"Omeprazole",
    "area":"Gastroenterology",
    "metabolizer_status":"Intermediate Metabolizer",
    "phenotype":"Intermediate Metabolizer",
    "diplotype":"*1/*2",
    "clinical_alert":{
      "recommendation_text":"Initiate standard starting daily dose. For chronic therapy (>12 weeks) and efficacy achieved, consider 50% reduction in daily dose and monitor for continued efficacy.",
      "classification":"Optional",
      "source":"CPIC",
      "guideline_version":"CYP2C19 and Proton Pump Inhibitors",
      "guideline_name":"CYP2C19 and Proton Pump Inhibitors",
      "citation_url":"https://www.clinpgx.org/guideline/PA166251441",
      "population":"general",
      "publication_date":null,
      "last_synced_at":"2026-07-30T17:37:18.906696Z",
      "comments":"n/a",
      "disclaimer":"This alert is guideline-based clinical decision support."
    },
    "alert_status":"found",
    "reason":null
  }],
  "ddi_alerts":[],
  "adr_alerts":[{
    "medicine_id":"639992c5-03b2-4175-a3fc-6ba860a61993",
    "reaction":"Hepatotoxicity",
    "severity":"Severe",
    "risk_factor":"Hepatic Impairment",
    "onset":"Delayed",
    "monitoring_parameter":"LFTs",
    "prevention_recommendation":"Baseline + monthly LFTs; stop if ALT > 3x ULN with symptoms"
  }],
  "oncology_eligibility":[]
}
''';
    final result = EngineCheckResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );

    expect(result.pgxAlerts, hasLength(1));
    expect(result.adrAlerts, hasLength(1));
    expect(result.ddiAlerts, isEmpty);
    expect(result.oncologyEligibility, isEmpty);

    final pgx = result.pgxAlerts.first;
    expect(pgx.gene, 'CYP2C19');
    expect(pgx.drugNameRaw, 'Omeprazole');
    expect(pgx.area, 'Gastroenterology');
    expect(pgx.metabolizerStatus, 'Intermediate Metabolizer');
    expect(pgx.phenotype, 'Intermediate Metabolizer');
    expect(pgx.diplotype, '*1/*2');
    expect(pgx.alertStatus, 'found');
    expect(pgx.reason, isNull);
    expect(pgx.clinicalAlert, isNotNull);
    expect(
      pgx.clinicalAlert!.recommendationText,
      contains('standard starting daily dose'),
    );
    expect(pgx.clinicalAlert!.classification, 'Optional');
    expect(pgx.clinicalAlert!.source, 'CPIC');
    expect(pgx.clinicalAlert!.citationUrl, contains('clinpgx.org'));
    expect(pgx.clinicalAlert!.comments, isNull); // n/a → null
    expect(pgx.message, contains('standard starting daily dose'));

    final adr = result.adrAlerts.first;
    expect(adr.title, 'Hepatotoxicity');
    expect(adr.severity, 'Severe');
    expect(adr.riskFactor, 'Hepatic Impairment');
    expect(adr.monitoring, 'LFTs');
  });

  test('parses string clinical_alert + oncology eligibility', () {
    const raw = r'''
{
  "pgx_alerts":[{
    "medicine_id":"5e6fb686-e345-46b7-a90f-91fdc9d90e8c",
    "gene":"CYP2C9",
    "drug_name_raw":"Warfarin",
    "area":"Multi-specialty",
    "metabolizer_status":"Normal Metabolizer",
    "phenotype":"Normal Metabolizer",
    "diplotype":"*1/*1",
    "clinical_alert":"Normal standard dosing VKORC1 warrants INR monitoring",
    "alert_status":"no_recommendation_found",
    "reason":"no_guideline_mapping"
  }],
  "ddi_alerts":[],
  "adr_alerts":[{
    "medicine_id":"5e6fb686-e345-46b7-a90f-91fdc9d90e8c",
    "reaction":"Bleeding",
    "severity":"Life-threatening",
    "risk_factor":"Elderly (65+)",
    "onset":"Acute",
    "monitoring_parameter":"INR",
    "prevention_recommendation":"Frequent INR monitoring"
  }],
  "oncology_eligibility":[{
    "medicine_id":"7b368271-745b-4d8d-8645-e8d0e5d715f2",
    "biomarker_type":"TMB",
    "patient_value":null,
    "patient_status":null,
    "required_status":"High",
    "eligible":false,
    "recommendation":"TMB-High required for pembrolizumab eligibility per label",
    "severity":"flag"
  }]
}
''';
    final result = EngineCheckResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );

    final pgx = result.pgxAlerts.single;
    expect(pgx.clinicalAlert, isNull);
    expect(
      pgx.clinicalAlertText,
      'Normal standard dosing VKORC1 warrants INR monitoring',
    );
    expect(pgx.message, contains('Normal standard dosing'));
    expect(pgx.alertStatus, 'no_recommendation_found');
    expect(pgx.reason, 'no_guideline_mapping');

    final onc = result.oncologyEligibility.single;
    expect(onc.biomarkerType, 'TMB');
    expect(onc.patientValue, isNull);
    expect(onc.patientStatus, isNull);
    expect(onc.requiredStatus, 'High');
    expect(onc.eligible, isFalse);
    expect(onc.recommendation, contains('pembrolizumab'));
    expect(onc.severity, 'flag');
    expect(onc.isCritical, isTrue); // eligible == false
  });
}
