import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/engine_check_model.dart';
import '../models/medicine_model.dart';

class MedicineRepository {
  Future<List<MedicineModel>> searchMedicines({
    String? search,
    int skip = 0,
    int limit = 30,
  }) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.medicines,
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      final raw = response.data;
      final list = (raw is List ? raw : <dynamic>[])
          .whereType<Map>()
          .map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MedicineModel> getMedicine(String medicineId) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.medicine(medicineId),
      );
      return MedicineModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MedicineModel> createMedicine(MedicineModel medicine) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.medicines,
        data: medicine.toCreateJson(),
      );
      return MedicineModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    try {
      final response = await DioClient.instance.put(
        ApiEndpoints.medicine(medicine.id),
        data: medicine.toUpdateJson(),
      );
      return MedicineModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    try {
      await DioClient.instance.delete(ApiEndpoints.medicine(medicineId));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EngineCheckResponse> runEngineCheck({
    required String patientId,
    required List<String> medicineIds,
  }) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.engineCheck(patientId),
        data: {'medicine_ids': medicineIds},
      );

      final data = response.data;
      if (data is! Map) {
        throw const ApiException('Empty response from engine check.');
      }

      return EngineCheckResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
