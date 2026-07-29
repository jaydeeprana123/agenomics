import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/genomiki_job_model.dart';
import '../../shell/views/app_shell.dart';
import '../controllers/vcf_file_run_controller.dart';

class VcfFileRunView extends GetView<VcfFileRunController> {
  const VcfFileRunView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'VCF File Run — Genomiki Jobs',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadJobs(refresh: true),
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
                      title: 'VCF File Run',
                      subtitle:
                          'View Genomiki VCF submission jobs and processing status for this hospital.',
                      actions: [
                        AppButton(
                          label: 'Refresh',
                          variant: AppButtonVariant.secondary,
                          icon: Icons.refresh,
                          onPressed: () =>
                              controller.loadJobs(refresh: true),
                        ),
                      ],
                    ),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _JobsPanel(controller: controller),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: _DetailPanel(controller: controller),
                          ),
                        ],
                      )
                    else ...[
                      _JobsPanel(controller: controller),
                      const SizedBox(height: 14),
                      _DetailPanel(controller: controller),
                    ],
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

class _JobsPanel extends StatelessWidget {
  final VcfFileRunController controller;

  const _JobsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'SUBMISSION JOBS',
                    style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Obx(() {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.statusFilter.value,
                      isDense: true,
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                      items: VcfFileRunController.statusFilters
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s == 'All' ? 'All statuses' : s),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) controller.setStatusFilter(value);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Obx(() {
            if (controller.isLoading.value && controller.jobs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final error = controller.errorMessage.value;
            if (error != null && controller.jobs.isEmpty) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load jobs',
                subtitle: error,
                actionLabel: 'Retry',
                onAction: () => controller.loadJobs(),
              );
            }

            if (controller.jobs.isEmpty) {
              return const EmptyState(
                icon: Icons.science_outlined,
                title: 'No VCF jobs found',
                subtitle:
                    'No Genomiki submission jobs are available for this hospital yet.',
              );
            }

            return Column(
              children: controller.jobs
                  .map(
                    (job) => _JobListTile(
                      job: job,
                      selected: controller.selectedJob.value?.id == job.id,
                      onTap: () => controller.selectJob(job),
                      formatDate: controller.formatDate,
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _JobListTile extends StatelessWidget {
  final GenomikiJobModel job;
  final bool selected;
  final VoidCallback onTap;
  final String Function(DateTime?) formatDate;

  const _JobListTile({
    required this.job,
    required this.selected,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: const BorderSide(color: AppColors.borderLight),
              left: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.displayFilename,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color:
                            selected ? AppColors.primaryDark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sample ${job.displaySampleId} · ${formatDate(job.submittedAt)}',
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: job.submitStatus),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final VcfFileRunController controller;

  const _DetailPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final job = controller.selectedJob.value;
      final live = controller.liveStatus.value;

      if (job == null) {
        return const AppCard(
          child: EmptyState(
            icon: Icons.insights_outlined,
            title: 'No job selected',
            subtitle:
                'Select a submission from the list to view job details and processing status.',
          ),
        );
      }

      return Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'JOB DETAILS',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    _StatusChip(status: job.submitStatus),
                  ],
                ),
                const SizedBox(height: 12),
                _Kv(label: 'Genomiki job id', value: job.displayJobId),
                _Kv(label: 'Record id', value: job.id),
                _Kv(label: 'Source file', value: job.displayFilename),
                _Kv(label: 'Source format', value: job.sourceFormat),
                _Kv(label: 'Sample id', value: job.displaySampleId),
                _Kv(label: 'Submit status', value: job.submitStatus),
                _Kv(label: 'Status URL', value: job.statusUrl ?? '—'),
                _Kv(
                  label: 'Submitted at',
                  value: controller.formatDate(job.submittedAt),
                ),
                _Kv(
                  label: 'Last checked',
                  value: controller.formatDate(job.lastCheckedAt),
                ),
                _Kv(
                  label: 'Completed at',
                  value: controller.formatDate(job.completedAt),
                ),
                if (job.errorMessage != null &&
                    job.errorMessage!.trim().isNotEmpty)
                  _Kv(
                    label: 'Error',
                    value: job.errorMessage!,
                    emphasize: true,
                  ),
                const SizedBox(height: 14),
                Obx(() {
                  final busy = controller.isCheckingStatus.value;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        label: 'Check live status',
                        icon: Icons.sensors,
                        isLoading: busy,
                        onPressed: busy
                            ? null
                            : () => controller.checkStatus(autoPoll: true),
                      ),
                      AppButton(
                        label: 'Force refresh',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.sync,
                        onPressed: busy ? null : controller.refreshSelectedJob,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PROCESSING STATUS',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                if (live == null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppColors.radius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      job.isInProgress
                          ? 'Job is ${job.submitStatus}. Use Check live status to poll Genomiki.'
                          : 'Latest stored status is ${job.submitStatus}. Run a live check for the authoritative Genomiki state.',
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      const Text(
                        'Genomiki status',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(status: live.genomikiStatus),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Kv(label: 'Live job id', value: live.jobId),
                  if (live.dbRecord != null)
                    _Kv(
                      label: 'Persisted status',
                      value: live.dbRecord!.submitStatus,
                    ),
                  const SizedBox(height: 10),
                  _ProgressStrip(status: live.genomikiStatus),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Kv extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _Kv({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Mulish',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Mulish',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: emphasize ? AppColors.error : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final type = switch (lower) {
      'complete' => StatusBadgeType.success,
      'running' => StatusBadgeType.info,
      'queued' => StatusBadgeType.teal,
      'failed' || 'error' => StatusBadgeType.error,
      _ => StatusBadgeType.off,
    };
    return StatusBadge(
      label: status.isEmpty ? 'unknown' : status,
      type: type,
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  final String status;

  const _ProgressStrip({required this.status});

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final steps = const ['queued', 'running', 'complete'];
    var activeIndex = steps.indexOf(lower);
    if (lower == 'failed' || lower == 'error') activeIndex = -1;

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final done = activeIndex >= index;
            final current = activeIndex == index;
            return Expanded(
              child: Container(
                margin:
                    EdgeInsets.only(right: index == steps.length - 1 ? 0 : 6),
                height: 8,
                decoration: BoxDecoration(
                  color: done ? AppColors.brand600 : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  border: current
                      ? Border.all(color: AppColors.brand400, width: 1.5)
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: steps
              .map(
                (step) => Expanded(
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        if (lower == 'failed' || lower == 'error') ...[
          const SizedBox(height: 10),
          const StatusBadge(
            label: 'Processing failed',
            type: StatusBadgeType.error,
          ),
        ],
      ],
    );
  }
}
