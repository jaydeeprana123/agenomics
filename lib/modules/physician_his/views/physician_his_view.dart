import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/engine_check_model.dart';
import '../../../data/models/medicine_model.dart';
import '../../../data/models/patient_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/physician_his_controller.dart';

class PhysicianHisView extends GetView<PhysicianHisController> {
  const PhysicianHisView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Physician Workflow • CDS Hooks',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final padding = Responsive.pagePadding(context);

          return GestureDetector(
            onTap: controller.clearResultsPanel,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: padding,
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _HisPanel(controller: controller),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 5,
                          child: _CdsPanel(controller: controller),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HisPanel(controller: controller),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          flex: 2,
                          child: _CdsPanel(controller: controller),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _HisPanel extends StatelessWidget {
  final PhysicianHisController controller;

  const _HisPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.slate,
            child: Row(
              children: [
                const Text(
                  'HIS SIMULATION',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x3322C55E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x664ADE80)),
                  ),
                  child: const Text(
                    'CDS Hooks Active',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF86EFAC),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final patient = controller.patient;
              if (patient == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PatientCard(patient: patient),
                    const SizedBox(height: 18),
                    const Text(
                      'PRESCRIBE MEDICATION — FIRES MEDICATION-PRESCRIBE HOOK',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MedicineSearch(controller: controller),
                    const SizedBox(height: 12),
                    _SelectedChips(controller: controller),
                    const SizedBox(height: 16),
                    Obx(() => AppButton(
                          label: 'Run',
                          icon: Icons.play_arrow_rounded,
                          expanded: true,
                          height: 44,
                          isLoading: controller.isRunning.value,
                          onPressed: controller.isRunning.value
                              ? null
                              : controller.runEngineCheck,
                        )),
                    Obx(() {
                      final err = controller.engineError.value;
                      if (err == null || err.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          err,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientModel patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final age = patient.age;
    final gender = patient.gender.isNotEmpty
        ? patient.gender[0].toUpperCase()
        : '—';
    final metaParts = <String>[
      'MRN ${patient.uhid}',
      if (age != null) '$gender/$age' else gender,
      if (patient.city != null && patient.city!.isNotEmpty) patient.city!,
      if (patient.source.isNotEmpty) patient.source,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            patient.name,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metaParts.join('  |  '),
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xB3FFFFFF),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: patient.isActive ? 'Active patient' : 'Inactive',
                color: patient.isActive
                    ? const Color(0xFF34D399)
                    : const Color(0xFFF87171),
              ),
              if (patient.emiratesId != null &&
                  patient.emiratesId!.isNotEmpty)
                const _Badge(
                  label: 'Emirates ID on file',
                  color: Color(0xFF60A5FA),
                ),
              if (patient.source.isNotEmpty)
                _Badge(
                  label: patient.source,
                  color: const Color(0xFFA78BFA),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MedicineSearch extends StatelessWidget {
  final PhysicianHisController controller;

  const _MedicineSearch({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.searchController,
          focusNode: controller.searchFocus,
          style: const TextStyle(
            fontFamily: 'Mulish',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Search Medicine...',
            hintStyle: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: Obx(() {
              if (controller.isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
        ),
        Obx(() {
          if (!controller.showResults.value) return const SizedBox.shrink();

          final error = controller.searchError.value;
          final results = controller.searchResults;
          final query = controller.searchQuery.value;
          final loading = controller.isSearching.value;

          if (query.length < 2) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: loading && results.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : error != null
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          error,
                          style: const TextStyle(
                            fontFamily: 'Mulish',
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : results.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text(
                              'No medicines found.',
                              style: TextStyle(
                                fontFamily: 'Mulish',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: results.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, color: AppColors.borderLight),
                            itemBuilder: (context, index) {
                              final med = results[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  med.name,
                                  style: const TextStyle(
                                    fontFamily: 'Mulish',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                subtitle: med.requiresOncologyCheck
                                    ? const Text(
                                        'Requires oncology check',
                                        style: TextStyle(
                                          fontFamily: 'Mulish',
                                          fontSize: 11,
                                          color: AppColors.warning,
                                        ),
                                      )
                                    : null,
                                onTap: () => controller.selectMedicine(med),
                              );
                            },
                          ),
          );
        }),
      ],
    );
  }
}

class _SelectedChips extends StatelessWidget {
  final PhysicianHisController controller;

  const _SelectedChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedMedicines;
      if (selected.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Text(
            'Selected medicines will appear here.',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selected
            .map((med) => _MedicineChip(
                  medicine: med,
                  onRemove: () => controller.removeMedicine(med),
                ))
            .toList(),
      );
    });
  }
}

class _MedicineChip extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onRemove;

  const _MedicineChip({required this.medicine, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            medicine.name,
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CdsPanel extends StatelessWidget {
  final PhysicianHisController controller;

  const _CdsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'AGENOMICS CDS RESPONSE',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Obx(() {
                  final count = controller.engineResult.value?.activeCount ?? 0;
                  final hasRun = controller.hasRun.value;
                  if (!hasRun) return const SizedBox.shrink();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? AppColors.errorBg
                          : AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: count > 0
                            ? AppColors.errorRing
                            : AppColors.successRing,
                      ),
                    ),
                    child: Text(
                      count > 0 ? '$count ACTIVE' : 'CLEAR',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: count > 0
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: Obx(() {
              if (controller.isRunning.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Running engine check…',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!controller.hasRun.value) {
                return const _EmptyCdsState();
              }

              final result = controller.engineResult.value;
              if (result == null || result.isEmpty) {
                return const _ClearCdsState();
              }

              final alerts = result.allAlerts;
              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: alerts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final medName =
                      controller.medicineNameFor(alert.medicineId);
                  return _AlertCard(alert: alert, medicineName: medName);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptyCdsState extends StatelessWidget {
  const _EmptyCdsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.biotech_outlined, size: 40, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'CDS response will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Select medicines and click Run to fire the medication-prescribe hook.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearCdsState extends StatelessWidget {
  const _ClearCdsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(AppColors.radiusLarge),
          border: Border.all(color: AppColors.successRing),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No active clinical alerts',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Engine check completed with no PGx, DDI, ADR, or oncology flags for the selected medicines.',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final EngineAlert alert;
  final String medicineName;

  const _AlertCard({required this.alert, required this.medicineName});

  @override
  Widget build(BuildContext context) {
    final (accent, bg, label) = _severityStyle(alert);

    final headlineParts = <String>[
      if (alert.title != null && alert.title!.isNotEmpty) alert.title!,
      if (medicineName.isNotEmpty) medicineName,
    ];
    final headline = headlineParts.isEmpty
        ? alert.displayTitle
        : headlineParts.join(' + ');

    final body = alert.message ??
        alert.recommendation ??
        'Clinical guidance available for this finding.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusLarge),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '! $label — $headline',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            alert.hookLabel,
                            style: const TextStyle(
                              fontFamily: 'Mulish',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (alert.riskFactor != null ||
                        alert.onset != null ||
                        alert.monitoring != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (alert.riskFactor != null)
                            _MetaChip(
                              icon: Icons.warning_amber_rounded,
                              label: alert.riskFactor!,
                              bg: bg,
                              fg: accent,
                            ),
                          if (alert.onset != null)
                            _MetaChip(
                              icon: Icons.schedule,
                              label: 'Onset: ${alert.onset}',
                              bg: AppColors.surfaceLight,
                              fg: AppColors.textSecondary,
                            ),
                          if (alert.monitoring != null)
                            _MetaChip(
                              icon: Icons.monitor_heart_outlined,
                              label: alert.monitoring!,
                              bg: AppColors.infoBg,
                              fg: AppColors.info,
                            ),
                        ],
                      ),
                    ],
                    if (alert.recommendation != null &&
                        alert.recommendation != body) ...[
                      const SizedBox(height: 10),
                      Text(
                        alert.recommendation!,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ActionPill(
                          label: 'Review guidance',
                          filled: true,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        _ActionPill(
                          label: 'Acknowledge',
                          filled: false,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String) _severityStyle(EngineAlert alert) {
    if (alert.isCritical) {
      return (AppColors.error, AppColors.errorBg, 'WARNING');
    }
    if (alert.isWarning) {
      return (AppColors.warning, AppColors.warningBg, 'WARNING');
    }
    if (alert.category == 'oncology') {
      return (AppColors.info, AppColors.infoBg, 'INFO');
    }
    return (AppColors.warning, AppColors.warningBg, 'ALERT');
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final bool filled;
  final Color color;

  const _ActionPill({
    required this.label,
    required this.filled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: filled ? color : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }
}
