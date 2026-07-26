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
import '../../shell/views/app_shell.dart';
import '../controllers/patient_list_controller.dart';

class PatientListView extends GetView<PatientListController> {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Patients — Claim Checker Registry',
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
                      title: 'Patient List',
                      subtitle:
                          'Search, register, and continue claim document workflows.',
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
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.searchController,
                              onChanged: controller.onSearchChanged,
                              decoration: InputDecoration(
                                hintText:
                                    'Search by Name, UHID, Mobile, or Emirates ID',
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.patients.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.patients.isEmpty) {
                        return EmptyState(
                          icon: Icons.people_outline,
                          title: 'No patients found',
                          subtitle:
                              'Add a new patient to start the claim checker workflow.',
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
                                ? _PatientTable(controller: controller)
                                : _PatientCards(controller: controller),
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

class _PatientTable extends StatelessWidget {
  final PatientListController controller;

  const _PatientTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final patients = controller.patients;

      return Column(
        children: [
          // Header
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
                SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      'ACTIONS',
                      style: Theme.of(context).dataTableTheme.headingTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          ...patients.map((p) {
            return Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _DataRow(patient: p),
                    ),
                  ),
                  SizedBox(
                    width: 220,
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
            );
          }),
        ],
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).dataTableTheme.headingTextStyle;
    Widget cell(String label, double width) => SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(label, style: style),
          ),
        );

    return Row(
      children: [
        cell('UHID', 130),
        cell('NAME', 160),
        cell('MOBILE', 140),
        cell('GENDER', 90),
        cell('EMIRATES ID', 170),
        cell('SOURCE', 90),
        cell('STATUS', 100),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final PatientModel patient;

  const _DataRow({required this.patient});

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child, double width) => SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: child,
          ),
        );

    return Row(
      children: [
        cell(
          Text(
            patient.uhid,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          130,
        ),
        cell(Text(patient.name, style: const TextStyle(fontSize: 13)), 160),
        cell(Text(patient.mobile, style: const TextStyle(fontSize: 13)), 140),
        cell(Text(patient.gender, style: const TextStyle(fontSize: 13)), 90),
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

class _PatientCards extends StatelessWidget {
  final PatientListController controller;

  const _PatientCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.patients.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = controller.patients[index];
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
                const SizedBox(height: 8),
                _ActionButtons(patient: p, controller: controller),
              ],
            ),
          );
        },
      );
    });
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
          onPressed: () => controller.continuePatient(patient),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
  }
}

