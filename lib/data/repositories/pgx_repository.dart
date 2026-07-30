import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/pgx_result_model.dart';

/// PGx results — live `GET /api/v1/patients/{patient_id}/pgx-results`.
class PgxRepository {
  Future<List<PgxResultModel>> getPgxResults(String patientId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.pgxResults(patientId),
      );

      final raw = response.data;
      final list = (raw is List ? raw : <dynamic>[])
          .whereType<Map>()
          .map((e) => PgxResultModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
