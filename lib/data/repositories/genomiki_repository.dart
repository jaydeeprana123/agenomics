import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/genomiki_job_model.dart';

/// Genomiki VCF jobs — `/api/v1/integrations/genomiki/jobs`.
class GenomikiRepository {
  Future<List<GenomikiJobModel>> listJobs({
    String? status,
    String? sampleId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.genomikiJobs,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
          if (sampleId != null && sampleId.trim().isNotEmpty)
            'sample_id': sampleId.trim(),
        },
      );

      return _parseJobList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<GenomikiJobModel> getJob(String genomikiJobId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.genomikiJob(genomikiJobId),
      );
      return GenomikiJobModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<GenomikiLiveStatusModel> checkLiveStatus(String genomikiJobId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.genomikiJobStatus(genomikiJobId),
      );
      return GenomikiLiveStatusModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<GenomikiJobModel> refreshJob(String genomikiJobId) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.genomikiJobRefresh(genomikiJobId),
      );
      return GenomikiJobModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  List<GenomikiJobModel> _parseJobList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => GenomikiJobModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (raw is Map) {
      return [GenomikiJobModel.fromJson(Map<String, dynamic>.from(raw))];
    }
    return const [];
  }
}
