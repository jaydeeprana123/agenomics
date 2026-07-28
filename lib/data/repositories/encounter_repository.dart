import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/encounter_detail_model.dart';
import '../models/encounter_model.dart';

/// Encounter repository — live patient encounter endpoints.
class EncounterRepository {
  Future<List<EncounterModel>> getPatientEncounters(String patientId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.patientEncounters(patientId),
      );

      final raw = response.data;
      final list = (raw is List ? raw : <dynamic>[])
          .whereType<Map>()
          .map((e) => EncounterModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return list;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET `/api/v1/encounters/{encounter_id}` → `EncounterDetailResponse`.
  Future<EncounterDetailModel?> getEncounterById(String encounterId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.encounter(encounterId),
      );
      final raw = response.data;
      if (raw == null) return null;
      if (raw is! Map) return null;
      return EncounterDetailModel.fromJson(Map<String, dynamic>.from(raw));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDio(e);
    }
  }
}
