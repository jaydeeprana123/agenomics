import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/medicine_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/medicines_controller.dart';

class MedicinesView extends GetView<MedicinesController> {
  const MedicinesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Medicines — Formulary Registry',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadMedicines(refresh: true),
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
                      title: 'Medicines',
                      subtitle:
                          'Manage the formulary used by Physician / HIS engine checks. Add, edit, or remove medicines.',
                      actions: [
                        AppButton(
                          label: 'Refresh',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.refresh,
                          onPressed: () =>
                              controller.loadMedicines(refresh: true),
                        ),
                        AppButton(
                          label: 'Add Medicine',
                          icon: Icons.add,
                          onPressed: controller.openCreateDialog,
                        ),
                      ],
                    ),
                    _SearchBar(controller: controller),
                    const SizedBox(height: 12),
                    Obx(() {
                      final list = controller.medicines;
                      final error = controller.errorMessage.value;

                      if (controller.isLoading.value && list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (error != null && list.isEmpty) {
                        return EmptyState(
                          icon: Icons.error_outline,
                          title: 'Unable to load medicines',
                          subtitle: error,
                          actionLabel: 'Retry',
                          onAction: () => controller.loadMedicines(),
                        );
                      }

                      if (list.isEmpty) {
                        return EmptyState(
                          icon: Icons.medication_outlined,
                          title: 'No medicines found',
                          subtitle: controller.searchQuery.value.isEmpty
                              ? 'Add a medicine to start building the formulary.'
                              : 'No medicines match your search. Clear the query or try another name.',
                          actionLabel: controller.searchQuery.value.isEmpty
                              ? 'Add Medicine'
                              : 'Clear search',
                          onAction: controller.searchQuery.value.isEmpty
                              ? controller.openCreateDialog
                              : controller.clearSearch,
                        );
                      }

                      final useTable = !Responsive.isMobile(context);

                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: useTable
                            ? _MedicinesTable(
                                medicines: list,
                                controller: controller,
                              )
                            : _MedicinesCards(
                                medicines: list,
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

class _SearchBar extends StatelessWidget {
  final MedicinesController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Obx(() {
        final hasQuery = controller.searchQuery.value.isNotEmpty;
        return AppTextField(
          controller: controller.searchController,
          hint: 'Search medicines by name…',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: hasQuery
              ? IconButton(
                  tooltip: 'Clear',
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.close, size: 18),
                )
              : null,
          onChanged: controller.onSearchChanged,
        );
      }),
    );
  }
}

class _MedicinesTable extends StatelessWidget {
  final List<MedicineModel> medicines;
  final MedicinesController controller;

  const _MedicinesTable({
    required this.medicines,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: const Row(
            children: [
              Expanded(flex: 32, child: _ColLabel('NAME')),
              Expanded(flex: 22, child: _ColLabel('ONCOLOGY CHECK')),
              Expanded(flex: 28, child: _ColLabel('CREATED')),
              Expanded(flex: 18, child: _ColLabel('ACTIONS')),
            ],
          ),
        ),
        ...medicines.map(
          (medicine) => _MedicineRow(
            medicine: medicine,
            controller: controller,
          ),
        ),
      ],
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

class _MedicineRow extends StatelessWidget {
  final MedicineModel medicine;
  final MedicinesController controller;

  const _MedicineRow({
    required this.medicine,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 32,
            child: Text(
              medicine.name,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: medicine.requiresOncologyCheck ? 'Required' : 'Not required',
                type: medicine.requiresOncologyCheck
                    ? StatusBadgeType.warning
                    : StatusBadgeType.success,
              ),
            ),
          ),
          Expanded(
            flex: 28,
            child: Text(
              controller.formatCreatedAt(medicine.createdAt),
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 18,
            child: _ActionButtons(
              medicine: medicine,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicinesCards extends StatelessWidget {
  final List<MedicineModel> medicines;
  final MedicinesController controller;

  const _MedicinesCards({
    required this.medicines,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: medicines.map((medicine) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  _ActionButtons(
                    medicine: medicine,
                    controller: controller,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StatusBadge(
                label: medicine.requiresOncologyCheck
                    ? 'Oncology check required'
                    : 'Oncology check not required',
                type: medicine.requiresOncologyCheck
                    ? StatusBadgeType.warning
                    : StatusBadgeType.success,
              ),
              const SizedBox(height: 6),
              Text(
                'Created ${controller.formatCreatedAt(medicine.createdAt)}',
                style: const TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final MedicineModel medicine;
  final MedicinesController controller;

  const _ActionButtons({
    required this.medicine,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => controller.openEditDialog(medicine),
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppColors.primary,
        ),
        IconButton(
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => controller.confirmDelete(medicine),
          icon: const Icon(Icons.delete_outline, size: 18),
          color: AppColors.error,
        ),
      ],
    );
  }
}
