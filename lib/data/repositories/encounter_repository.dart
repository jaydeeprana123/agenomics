import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
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
}
