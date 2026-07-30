import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/pgx_result_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/genomics_analysis_controller.dart';

class GenomicsAnalysisView extends GetView<GenomicsAnalysisController> {
  const GenomicsAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Genomic Analysis',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadResults(refresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Responsive.pagePadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                  maxWidth: Responsive.contentMaxWidth(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      title: 'Genomic Analysis',
                      subtitle:
                          'CPIC v2024.2 pharmacogenomic panel results for the selected patient, with source provenance.',
                      actions: [
                        AppButton(
                          label: 'Refresh',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.refresh,
                          onPressed: () =>
                              controller.loadResults(refresh: true),
                        ),
                        Obx(
                          () => AppButton(
                            label: 'Download PDF Report',
                            icon: Icons.picture_as_pdf_outlined,
                            isLoading: controller.isDownloadingPdf.value,
                            onPressed: controller.patient == null ||
                                    (controller.patient?.id.isEmpty ?? true)
                                ? null
                                : controller.downloadPdfReport,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.panelRows.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final error = controller.errorMessage.value;
                      if (error != null && controller.panelRows.isEmpty) {
                        return EmptyState(
                          icon: Icons.error_outline,
                          title: 'Unable to load PGx results',
                          subtitle: error,
                          actionLabel: 'Retry',
                          onAction: () => controller.loadResults(),
                        );
                      }

                      return wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: _ResultsPanel(controller: controller),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 5,
                                  child: _SidePanels(controller: controller),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ResultsPanel(controller: controller),
                                const SizedBox(height: 14),
                                _SidePanels(controller: controller),
                              ],
                            );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  final GenomicsAnalysisController controller;

  const _ResultsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.panelRows;
      final patient = controller.patient;

      if (rows.isEmpty) {
        return AppCard(
          padding: EdgeInsets.zero,
          child: EmptyState(
            icon: Icons.biotech_outlined,
            title: 'Genomic data withheld',
            subtitle: patient == null
                ? 'No PGx panel results are available.'
                : '${patient.name} has no consented PGx results on file. No diplotype or phenotype data has been retrieved or processed.',
          ),
        );
      }

      return AppCard(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : 980.0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth < 720 ? 720 : tableWidth,
                child: Column(
                  children: [
                    const _TableHeader(),
                    ...rows.map((row) => _ResultRow(row: row)),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      child: const Row(
        children: [
          Expanded(flex: 14, child: _ColLabel('GENE')),
          Expanded(flex: 14, child: _ColLabel('DIPLOTYPE')),
          Expanded(flex: 20, child: _ColLabel('PHENOTYPE')),
          Expanded(flex: 8, child: _ColLabel('CPIC')),
          Expanded(flex: 44, child: _ColLabel('AFFECTED DRUGS')),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  final String label;

  const _ColLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final PgxPanelRow row;

  const _ResultRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 14,
            child: Text(
              row.gene,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.brand600,
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              row.diplotype,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.purple,
              ),
            ),
          ),
          Expanded(
            flex: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _PhenotypeBadge(label: row.phenotype),
            ),
          ),
          Expanded(
            flex: 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _CpicBadge(level: row.cpicLevel),
            ),
          ),
          Expanded(
            flex: 44,
            child: _AffectedDrugsCell(drugs: row.affectedDrugs),
          ),
        ],
      ),
    );
  }
}

class _AffectedDrugsCell extends StatelessWidget {
  final List<PgxAffectedDrug> drugs;

  const _AffectedDrugsCell({required this.drugs});

  @override
  Widget build(BuildContext context) {
    final visible = drugs.where((d) => d.hasDisplayContent).toList();
    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _AffectedDrugItem(drug: visible[i]),
          ],
        ],
      ),
    );
  }
}

class _AffectedDrugItem extends StatelessWidget {
  final PgxAffectedDrug drug;

  const _AffectedDrugItem({required this.drug});

  @override
  Widget build(BuildContext context) {
    final name = drug.drug?.trim();
    final recommendation = drug.recommendationText?.trim();
    final hasName = name != null && name.isNotEmpty;
    final hasRecommendation =
        recommendation != null && recommendation.isNotEmpty;

    if (!hasName && !hasRecommendation) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasName)
            Text(
              name,
              softWrap: true,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          if (hasName && hasRecommendation) const SizedBox(height: 3),
          if (hasRecommendation)
            Text(
              recommendation,
              softWrap: true,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _PhenotypeBadge extends StatelessWidget {
  final String label;

  const _PhenotypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final StatusBadgeType type;
    if (lower.contains('poor') ||
        lower.contains('ultrarapid') ||
        lower.contains('contra')) {
      type = StatusBadgeType.error;
    } else if (lower.contains('intermediate') ||
        lower.contains('increased') ||
        lower.contains('decreased')) {
      type = StatusBadgeType.warning;
    } else if (lower.contains('normal') || lower.contains('extensive')) {
      type = StatusBadgeType.success;
    } else {
      type = StatusBadgeType.info;
    }

    return StatusBadge(label: label, type: type);
  }
}

class _CpicBadge extends StatelessWidget {
  final String level;

  const _CpicBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    if (level == '—' || level.trim().isEmpty) {
      return const Text(
        '—',
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      );
    }

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brand400, width: 1.4),
      ),
      child: Text(
        level,
        style: const TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.brand700,
        ),
      ),
    );
  }
}

class _SidePanels extends StatelessWidget {
  final GenomicsAnalysisController controller;

  const _SidePanels({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => _ProvenanceCard(
            source: controller.sourceLabel,
            pharmCatRun: controller.pharmCatRunLabel,
          ),
        ),
        const SizedBox(height: 14),
        const _RawDnaCard(),
      ],
    );
  }
}

class _ProvenanceCard extends StatelessWidget {
  final String source;
  final String pharmCatRun;

  const _ProvenanceCard({required this.source, required this.pharmCatRun});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'DATA PROVENANCE',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          _ProvRow(label: 'Source', value: source),
          const _ProvRow(label: 'Consent policy', value: 'EGP-OPTIN-v2'),
          const _ProvRow(label: 'EIDA assurance', value: 'IAL2 · Verified'),
          _ProvRow(label: 'PharmCAT run', value: pharmCatRun),
          const _ProvRow(
            label: 'Raw DNA accessed',
            valueWidget: StatusBadge(
              label: 'Never',
              type: StatusBadgeType.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _ProvRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  valueWidget ??
                  Text(
                    value ?? '—',
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RawDnaCard extends StatelessWidget {
  const _RawDnaCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'RAW DNA HANDLING',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: AppColors.successRing),
            ),
            child: const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12,
                  height: 1.55,
                  color: Color(0xFF065F46),
                ),
                children: [
                  TextSpan(
                    text: 'Raw sequence never leaves the edge node. ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        'PharmCAT runs on-premise inside the hospital firewall. Only interpreted diplotype/phenotype enters the canonical object; FASTQ/BAM/CRAM are never transmitted, stored centrally, or exposed to any API.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
