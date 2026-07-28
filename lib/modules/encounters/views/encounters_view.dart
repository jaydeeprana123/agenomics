import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/encounter_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/encounters_controller.dart';

class EncountersView extends GetView<EncountersController> {
  const EncountersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Encounters — Patient Visits',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadEncounters(refresh: true),
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
                    Obx(() {
                      final patient = controller.patient;
                      return PageHeader(
                        title: 'Encounters',
                        subtitle: patient == null
                            ? 'Select a patient to load visits.'
                            : 'Visits for ${patient.name} (${patient.uhid}). Click a row to set the active visit.',
                        actions: [
                          AppButton(
                            label: 'Refresh',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.refresh,
                            onPressed: () =>
                                controller.loadEncounters(refresh: true),
                          ),
                        ],
                      );
                    }),
                    _SelectedVisitBanner(controller: controller),
                    const SizedBox(height: 12),
                    Obx(() {
                      controller.selectedEncounter.selected.value;
                      final list = controller.encounters;

                      if (controller.isLoading.value && list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final error = controller.errorMessage.value;
                      if (error != null && list.isEmpty) {
                        return EmptyState(
                          icon: Icons.error_outline,
                          title: 'Unable to load encounters',
                          subtitle: error,
                          actionLabel: 'Retry',
                          onAction: () => controller.loadEncounters(),
                        );
                      }

                      if (list.isEmpty) {
                        return const EmptyState(
                          icon: Icons.event_note_outlined,
                          title: 'No encounters found',
                          subtitle:
                              'This patient has no visits yet. Pull to refresh after new data is available.',
                        );
                      }

                      final useTable = !Responsive.isMobile(context);

                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: useTable
                            ? _EncountersTable(
                                encounters: list,
                                controller: controller,
                              )
                            : _EncountersCards(
                                encounters: list,
                                controller: controller,
                              ),
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

class _SelectedVisitBanner extends StatelessWidget {
  final EncountersController controller;

  const _SelectedVisitBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final encounter = controller.selectedEncounter.selected.value;
      if (encounter == null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No visit selected. Click a row to set the active encounter for all screens.',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(color: AppColors.primaryMid),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available,
              size: 16,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected visit: ${encounter.displayLabel}'
                '${encounter.displayMeta.isNotEmpty ? ' · ${encounter.displayMeta}' : ''}',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 12,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EncountersTable extends StatelessWidget {
  final List<EncounterModel> encounters;
  final EncountersController controller;

  const _EncountersTable({required this.encounters, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _HeaderRow(),
                ),
              ),
              const SizedBox(
                width: 72,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...encounters.map((encounter) {
          final isSelected = controller.selectedEncounter.isSelected(encounter);
          return Material(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            child: InkWell(
              onTap: () => controller.selectEncounter(encounter),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: const BorderSide(color: AppColors.borderLight),
                    left: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _DataRow(
                          encounter: encounter,
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'View',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            onPressed: () =>
                                controller.viewEncounter(encounter),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, double width) => SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );

    return Row(
      children: [
        cell('VISIT ID', 150),
        cell('TYPE', 120),
        cell('CLASS', 110),
        cell('LOCATION', 140),
        cell('PROVIDER', 160),
        cell('ADMITTED', 150),
        cell('DISCHARGED', 150),
        cell('STATUS', 100),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final EncounterModel encounter;
  final bool isSelected;

  const _DataRow({required this.encounter, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child, double width) => SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: child,
      ),
    );

    final textStyle = TextStyle(
      fontFamily: 'Mulish',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isSelected ? AppColors.primaryDark : AppColors.text,
    );

    return Row(
      children: [
        cell(
          Text(
            encounter.visitId,
            style: textStyle.copyWith(fontWeight: FontWeight.w800),
          ),
          150,
        ),
        cell(Text(encounter.encounterType ?? '—', style: textStyle), 120),
        cell(
          Text(
            encounter.visitClass ?? encounter.patientClass ?? '—',
            style: textStyle,
          ),
          110,
        ),
        cell(Text(encounter.location ?? '—', style: textStyle), 140),
        cell(
          Text(encounter.attendingProviderName ?? '—', style: textStyle),
          160,
        ),
        cell(
          Text(_formatDateTime(encounter.admitDatetime), style: textStyle),
          150,
        ),
        cell(
          Text(_formatDateTime(encounter.dischargeDatetime), style: textStyle),
          150,
        ),
        cell(
          StatusBadge(
            label: encounter.isOpen ? 'Open' : 'Closed',
            type: encounter.isOpen
                ? StatusBadgeType.success
                : StatusBadgeType.off,
          ),
          100,
        ),
      ],
    );
  }
}

class _EncountersCards extends StatelessWidget {
  final List<EncounterModel> encounters;
  final EncountersController controller;

  const _EncountersCards({required this.encounters, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: encounters.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final encounter = encounters[index];
        final isSelected = controller.selectedEncounter.isSelected(encounter);

        return Material(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          child: InkWell(
            onTap: () => controller.selectEncounter(encounter),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          encounter.visitId,
                          style: TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.text,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'View',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () => controller.viewEncounter(encounter),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        color: AppColors.info,
                      ),
                      StatusBadge(
                        label: encounter.isOpen ? 'Open' : 'Closed',
                        type: encounter.isOpen
                            ? StatusBadgeType.success
                            : StatusBadgeType.off,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Builder(
                    builder: (_) {
                      final parts = <String>[
                        if (encounter.encounterType != null)
                          encounter.encounterType!,
                        if (encounter.visitClass != null) encounter.visitClass!,
                        if (encounter.location != null) encounter.location!,
                      ];
                      return Text(
                        parts.isEmpty
                            ? 'Visit details unavailable'
                            : parts.join(' · '),
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  if (encounter.attendingProviderName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      encounter.attendingProviderName!,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Admitted ${_formatDateTime(encounter.admitDatetime)}'
                    '${encounter.dischargeDatetime != null ? ' · Discharged ${_formatDateTime(encounter.dischargeDatetime)}' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '—';
  return DateFormat('dd MMM yyyy, HH:mm').format(value.toLocal());
}
