import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/encounter_detail_model.dart';

/// Scrollable dialog showing full encounter details from the API.
class EncounterDetailsDialog extends StatelessWidget {
  final EncounterDetailModel details;

  const EncounterDetailsDialog({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final maxWidth = MediaQuery.of(context).size.width > 720
        ? 640.0
        : MediaQuery.of(context).size.width * 0.92;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              details.visitId.isNotEmpty ? details.visitId : 'Encounter Details',
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          StatusBadge(
            label: details.isOpen ? 'Open' : 'Closed',
            type: details.isOpen
                ? StatusBadgeType.success
                : StatusBadgeType.off,
          ),
        ],
      ),
      content: SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                title: 'Visit summary',
                child: Column(
                  children: [
                    _DetailRow('Encounter ID', details.id),
                    _DetailRow('Visit ID', details.visitId),
                    _DetailRow('Type', details.encounterType ?? '—'),
                    _DetailRow(
                      'Class',
                      details.visitClass ?? details.patientClass ?? '—',
                    ),
                    _DetailRow('Location', details.location ?? '—'),
                    _DetailRow(
                      'Provider',
                      details.attendingProviderName ?? '—',
                    ),
                    _DetailRow(
                      'Admitted',
                      _formatDateTime(details.admitDatetime),
                    ),
                    _DetailRow(
                      'Discharged',
                      _formatDateTime(details.dischargeDatetime),
                    ),
                  ],
                ),
              ),
              _ListSection(
                title: 'Diagnoses',
                emptyLabel: 'No diagnoses recorded for this visit.',
                items: details.diagnoses,
                itemBuilder: (item) => _BulletItem(
                  title: item.description.isNotEmpty
                      ? item.description
                      : item.code,
                  subtitle: [
                    if (item.code.isNotEmpty) item.code,
                    if (item.codeSystem.isNotEmpty) item.codeSystem,
                    if (item.status.isNotEmpty) item.status,
                    if (item.diagnosisDatetime != null)
                      _formatDateTime(item.diagnosisDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Procedures',
                emptyLabel: 'No procedures recorded for this visit.',
                items: details.procedures,
                itemBuilder: (item) => _BulletItem(
                  title: item.description.isNotEmpty
                      ? item.description
                      : item.code,
                  subtitle: [
                    if (item.code.isNotEmpty) item.code,
                    if (item.performingProvider != null)
                      item.performingProvider!,
                    if (item.procedureDatetime != null)
                      _formatDateTime(item.procedureDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Observations',
                emptyLabel: 'No observations recorded for this visit.',
                items: details.observations,
                itemBuilder: (item) => _BulletItem(
                  title: item.observationIdentifier.isNotEmpty
                      ? item.observationIdentifier
                      : 'Observation',
                  subtitle: [
                    '${item.value}${item.units != null ? ' ${item.units}' : ''}',
                    if (item.resultStatus.isNotEmpty) item.resultStatus,
                    if (item.abnormalFlag != null) item.abnormalFlag!,
                    if (item.observationDatetime != null)
                      _formatDateTime(item.observationDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Diagnostic reports',
                emptyLabel: 'No diagnostic reports for this visit.',
                items: details.diagnosticReports,
                itemBuilder: (item) => _BulletItem(
                  title: item.reportCode,
                  subtitle: [
                    if (item.category != null) item.category!,
                    if (item.performerName != null) item.performerName!,
                    if (item.conclusion != null) item.conclusion!,
                    if (item.issuedDatetime != null)
                      _formatDateTime(item.issuedDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Medication orders',
                emptyLabel: 'No medication orders for this visit.',
                items: details.medicationOrders,
                itemBuilder: (item) => _BulletItem(
                  title: item.drugName,
                  subtitle: [
                    if (item.ndcCode.isNotEmpty) item.ndcCode,
                    if (item.dose != null) item.dose!,
                    if (item.route != null) item.route!,
                    if (item.orderingProvider != null) item.orderingProvider!,
                    if (item.orderDatetime != null)
                      _formatDateTime(item.orderDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Medication dispenses',
                emptyLabel: 'No medication dispenses for this visit.',
                items: details.medicationDispenses,
                itemBuilder: (item) => _BulletItem(
                  title: item.drugName,
                  subtitle: [
                    if (item.ndcCode.isNotEmpty) item.ndcCode,
                    if (item.quantityDispensed != null)
                      item.quantityDispensed!,
                    if (item.dispensingPharmacy != null)
                      item.dispensingPharmacy!,
                    if (item.dispenseDatetime != null)
                      _formatDateTime(item.dispenseDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Clinical alerts',
                emptyLabel: 'No clinical alerts for this visit.',
                items: details.clinicalAlerts,
                itemBuilder: (item) => _BulletItem(
                  title: item.message.isNotEmpty ? item.message : item.code,
                  subtitle: [
                    if (item.severity.isNotEmpty) item.severity,
                    if (item.code.isNotEmpty) item.code,
                    if (item.raisedDatetime != null)
                      _formatDateTime(item.raisedDatetime),
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Insurance',
                emptyLabel: 'No insurance records for this visit.',
                items: details.insurances,
                itemBuilder: (item) => _BulletItem(
                  title: item.payerName,
                  subtitle: [
                    if (item.planId != null) 'Plan ${item.planId}',
                    if (item.policyNumber != null)
                      'Policy ${item.policyNumber}',
                    if (item.memberId != null) 'Member ${item.memberId}',
                    if (item.subscriberName != null) item.subscriberName!,
                  ].join(' · '),
                ),
              ),
              _ListSection(
                title: 'Documents',
                emptyLabel: 'No documents linked to this visit.',
                items: details.documents,
                itemBuilder: (item) => _BulletItem(
                  title: item.title ?? 'Document',
                  subtitle: [
                    if (item.mimeType != null) item.mimeType!,
                    if (item.createdAt != null)
                      _formatDateTime(item.createdAt),
                  ].join(' · '),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ListSection<T> extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  const _ListSection({
    required this.title,
    required this.emptyLabel,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '$title (${items.length})',
      child: items.isEmpty
          ? Text(
              emptyLabel,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: itemBuilder(item),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BulletItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '—';
  return DateFormat('dd MMM yyyy, HH:mm').format(value.toLocal());
}
