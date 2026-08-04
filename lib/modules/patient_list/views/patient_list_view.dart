import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/patient_model.dart';
import '../../shell/controllers/selected_patient_controller.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/patient_list_controller.dart';

class PatientListView extends GetView<PatientListController> {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Patient Cohort — Claim Checker Registry',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadPatients(refresh: true),
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
                      title: 'Patient Cohort',
                      subtitle:
                          'Click any patient to open their encounters. Search and filter the registry below.',
                      actions: [
                        AppButton(
                          label: 'Refresh',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.refresh,
                          onPressed: () =>
                              controller.loadPatients(refresh: true),
                        ),
                        AppButton(
                          label: 'Add New Patient',
                          icon: Icons.add,
                          onPressed: controller.goToAddPatient,
                        ),
                      ],
                    ),
                    _SelectedBanner(controller: controller),
                    const SizedBox(height: 12),
                    _SearchAndFilters(controller: controller),
                    const SizedBox(height: 12),
                    Obx(() {
                      // Depend on filters + selection + list
                      controller.genderFilter.value;
                      controller.statusFilter.value;
                      controller.selectedPatient.selected.value;
                      final list = controller.filteredPatients;

                      if (controller.isLoading.value &&
                          controller.patients.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (list.isEmpty) {
                        return EmptyState(
                          icon: Icons.people_outline,
                          title: 'No patients found',
                          subtitle:
                              'Add a new patient or clear filters to see the cohort.',
                          actionLabel: 'Add New Patient',
                          onAction: controller.goToAddPatient,
                        );
                      }

                      final useTable = !Responsive.isMobile(context);

                      return Column(
                        children: [
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: useTable
                                ? _CohortTable(
                                    patients: list,
                                    controller: controller,
                                  )
                                : _CohortCards(
                                    patients: list,
                                    controller: controller,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          _PaginationBar(controller: controller),
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

class _SelectedBanner extends StatelessWidget {
  final PatientListController controller;

  const _SelectedBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final patient = controller.selectedPatient.selected.value;
      if (patient == null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No patient selected. Click a row to open Encounters for that patient.',
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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '${patient.uhid} · ${patient.gender}'
                    '${patient.age != null ? ' · ${patient.age} yrs' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: 'Active selection',
              type: StatusBadgeType.success,
              showDot: true,
            ),
          ],
        ),
      );
    });
  }
}

class _SearchAndFilters extends StatelessWidget {
  final PatientListController controller;

  const _SearchAndFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by Name, UHID, Mobile, or Emirates ID',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.clear, size: 18),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Gender',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Obx(
                () => _FilterChips(
                  options: const ['All', 'Male', 'Female', 'Other'],
                  value: controller.genderFilter.value,
                  onChanged: controller.setGenderFilter,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Status',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Obx(
                () => _FilterChips(
                  options: const ['All', 'Active', 'Inactive'],
                  value: controller.statusFilter.value,
                  onChanged: controller.setStatusFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const _FilterChips({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: options.map((option) {
        final selected = option == value;
        return InkWell(
          onTap: () => onChanged(option),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final PatientListController controller;

  const _PaginationBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Page ${controller.currentPage.value} of ${controller.lastPage.value} · ${controller.total.value} total',
            style: const TextStyle(
              fontFamily: 'Mulish',
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            label: 'Prev',
            variant: AppButtonVariant.secondary,
            onPressed: controller.currentPage.value > 1
                ? controller.previousPage
                : null,
            height: 34,
          ),
          const SizedBox(width: 6),
          AppButton(
            label: 'Next',
            variant: AppButtonVariant.secondary,
            onPressed: controller.currentPage.value < controller.lastPage.value
                ? controller.nextPage
                : null,
            height: 34,
          ),
        ],
      );
    });
  }
}

class _CohortTable extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientListController controller;

  const _CohortTable({
    required this.patients,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final selected = Get.find<SelectedPatientController>();

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _HeaderRow(),
                ),
              ),
              const SizedBox(
                width: 280,
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
        ...patients.map((p) {
          final isSelected = selected.isSelected(p);
          return Material(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            child: InkWell(
              onTap: () => controller.openPatientEncounters(p),
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
                        child: _DataRow(patient: p, isSelected: isSelected),
                      ),
                    ),
                    SizedBox(
                      width: 280,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: _ActionButtons(
                          patient: p,
                          controller: controller,
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
        cell('UHID', 130),
        cell('PATIENT', 170),
        cell('AGE / SEX', 90),
        cell('MOBILE', 140),
        cell('EMIRATES ID', 170),
        cell('SOURCE', 90),
        cell('STATUS', 100),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final PatientModel patient;
  final bool isSelected;

  const _DataRow({
    required this.patient,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child, double width) => SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: child,
          ),
        );

    final ageSex = [
      if (patient.age != null) '${patient.age}',
      if (patient.gender.isNotEmpty) patient.gender[0].toUpperCase(),
    ].join('');

    return Row(
      children: [
        cell(
          Text(
            patient.uhid,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isSelected ? AppColors.primaryDark : AppColors.text,
            ),
          ),
          130,
        ),
        cell(
          Text(
            patient.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primaryDark : AppColors.text,
            ),
          ),
          170,
        ),
        cell(Text(ageSex.isEmpty ? '—' : ageSex, style: const TextStyle(fontSize: 13)), 90),
        cell(Text(patient.mobile, style: const TextStyle(fontSize: 13)), 140),
        cell(
          Text(patient.emiratesId ?? '—', style: const TextStyle(fontSize: 13)),
          170,
        ),
        cell(Text(patient.source, style: const TextStyle(fontSize: 13)), 90),
        cell(
          StatusBadge(
            label: patient.isActive ? 'Active' : 'Inactive',
            type: patient.isActive
                ? StatusBadgeType.success
                : StatusBadgeType.off,
          ),
          100,
        ),
      ],
    );
  }
}

class _CohortCards extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientListController controller;

  const _CohortCards({
    required this.patients,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final selected = Get.find<SelectedPatientController>();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = patients[index];
        final isSelected = selected.isSelected(p);

        return Material(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          child: InkWell(
            onTap: () => controller.openPatientEncounters(p),
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
                          p.name,
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
                      StatusBadge(
                        label: p.isActive ? 'Active' : 'Inactive',
                        type: p.isActive
                            ? StatusBadgeType.success
                            : StatusBadgeType.off,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.uhid} · ${p.mobile}',
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (p.emiratesId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      p.emiratesId!,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _ActionButtons(patient: p, controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final PatientModel patient;
  final PatientListController controller;

  const _ActionButtons({
    required this.patient,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final consentStatus = controller.consent.statusFor(patient.id);
      final creating = controller.consent.isCreating(patient.id);

      return Wrap(
        spacing: 0,
        runSpacing: 0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            tooltip: 'View',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => controller.viewPatient(patient),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            color: AppColors.info,
          ),
          IconButton(
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => controller.editPatient(patient),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => controller.deletePatient(patient),
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
          ),
          TextButton(
            onPressed: creating ? null : () => controller.requestConsent(patient),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primaryDark,
            ),
            child: creating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Consent',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      if (consentStatus != null) ...[
                        const SizedBox(width: 4),
                        _ConsentStatusDot(status: consentStatus.status),
                      ],
                    ],
                  ),
          ),
          TextButton(
            onPressed: () => controller.continuePatient(patient),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ConsentStatusDot extends StatelessWidget {
  final String status;

  const _ConsentStatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'approved' => AppColors.success,
      'declined' => AppColors.warning,
      _ => AppColors.info,
    };
    final label = switch (status) {
      'approved' => 'OK',
      'declined' => 'No',
      _ => '…',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Mulish',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
