import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/genomiki_job_model.dart';
import '../../../data/repositories/genomiki_repository.dart';

class VcfFileRunController extends GetxController {
  VcfFileRunController({GenomikiRepository? repository})
      : _repository = repository ?? Get.find<GenomikiRepository>();

  final GenomikiRepository _repository;

  final jobs = <GenomikiJobModel>[].obs;
  final selectedJob = Rxn<GenomikiJobModel>();
  final liveStatus = Rxn<GenomikiLiveStatusModel>();

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isCheckingStatus = false.obs;
  final errorMessage = RxnString();

  final statusFilter = 'All'.obs;

  Timer? _pollTimer;
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm:ss');

  static const statusFilters = [
    'All',
    'queued',
    'running',
    'complete',
    'failed',
    'error',
  ];

  @override
  void onInit() {
    super.onInit();
    loadJobs();
  }

  String formatDate(DateTime? value) {
    if (value == null) return '—';
    return _dateFormat.format(value.toLocal());
  }

  Future<void> loadJobs({bool refresh = false}) async {
    if (isClosed) return;

    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final filter =
          statusFilter.value == 'All' ? null : statusFilter.value;
      final list = await _repository.listJobs(
        status: filter,
        limit: 100,
      );
      if (isClosed) return;

      list.sort((a, b) {
        final aAt = a.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bAt = b.submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bAt.compareTo(aAt);
      });
      jobs.assignAll(list);

      final current = selectedJob.value;
      if (current != null) {
        GenomikiJobModel? match;
        for (final job in list) {
          if (job.id == current.id ||
              (current.jobId != null &&
                  current.jobId!.isNotEmpty &&
                  job.jobId == current.jobId)) {
            match = job;
            break;
          }
        }
        if (match != null) {
          selectedJob.value = match;
        } else {
          selectedJob.value = null;
          liveStatus.value = null;
        }
      } else if (list.isNotEmpty) {
        selectedJob.value = list.first;
      }
    } on ApiException catch (e) {
      if (isClosed) return;
      errorMessage.value = e.message;
      Get.snackbar(
        'Unable to load VCF jobs',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      if (isClosed) return;
      errorMessage.value = 'Unexpected error while loading VCF jobs.';
      Get.snackbar(
        'Unable to load VCF jobs',
        errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    loadJobs();
  }

  void selectJob(GenomikiJobModel job) {
    selectedJob.value = job;
    liveStatus.value = null;
    _stopPolling();
  }

  Future<void> checkStatus({bool autoPoll = false}) async {
    final job = selectedJob.value;
    final genomikiId = job?.jobId;
    if (job == null || genomikiId == null || genomikiId.isEmpty) {
      Get.snackbar(
        'No Genomiki job id',
        'This record has no Genomiki job_id to check yet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
      );
      return;
    }

    isCheckingStatus.value = true;
    try {
      final status = await _repository.checkLiveStatus(genomikiId);
      if (isClosed) return;

      liveStatus.value = status;
      if (status.dbRecord != null) {
        selectedJob.value = status.dbRecord;
        _upsertJob(status.dbRecord!);
      } else {
        selectedJob.value = job.copyWith(submitStatus: status.genomikiStatus);
      }

      if (autoPoll || status.dbRecord?.isInProgress == true) {
        final current = selectedJob.value;
        if (current != null && current.isInProgress) {
          _startPolling();
        } else {
          _stopPolling();
        }
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Status check failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      Get.snackbar(
        'Status check failed',
        'Unexpected error while checking Genomiki status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) isCheckingStatus.value = false;
    }
  }

  Future<void> refreshSelectedJob() async {
    final job = selectedJob.value;
    final genomikiId = job?.jobId;
    if (job == null || genomikiId == null || genomikiId.isEmpty) {
      Get.snackbar(
        'No Genomiki job id',
        'This record has no Genomiki job_id to refresh yet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
      );
      return;
    }

    isCheckingStatus.value = true;
    try {
      final updated = await _repository.refreshJob(genomikiId);
      if (isClosed) return;
      selectedJob.value = updated;
      _upsertJob(updated);
      liveStatus.value = GenomikiLiveStatusModel(
        jobId: updated.jobId ?? genomikiId,
        genomikiStatus: updated.submitStatus,
        dbRecord: updated,
      );

      if (updated.isInProgress) {
        _startPolling();
      } else {
        _stopPolling();
      }

      Get.snackbar(
        'Status refreshed',
        'Job is now ${updated.submitStatus}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Refresh failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } catch (_) {
      Get.snackbar(
        'Refresh failed',
        'Unexpected error while refreshing job status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      if (!isClosed) isCheckingStatus.value = false;
    }
  }

  void _upsertJob(GenomikiJobModel job) {
    final index = jobs.indexWhere(
      (j) => j.id == job.id || (j.jobId != null && j.jobId == job.jobId),
    );
    if (index >= 0) {
      jobs[index] = job;
    } else {
      jobs.insert(0, job);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final job = selectedJob.value;
      if (job == null || !job.isInProgress) {
        _stopPolling();
        return;
      }
      checkStatus();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }
}
