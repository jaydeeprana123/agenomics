import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/paginated_result.dart';
import '../models/patient_model.dart';

/// Patient repository — live `/api/v1/patients` endpoints.
class PatientRepository {
  Future<PaginatedResult<PatientModel>> getPatients({
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final skip = (page - 1) * perPage;
      final response = await DioClient.instance.get(
        ApiEndpoints.patients,
        queryParameters: {
          'skip': skip,
          'limit': perPage,
        },
      );

      final raw = response.data;
      final list = (raw is List ? raw : <dynamic>[])
          .whereType<Map>()
          .map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      var filtered = list;
      if (search != null && search.trim().isNotEmpty) {
        final q = search.trim().toLowerCase();
        filtered = list.where((p) {
          return p.name.toLowerCase().contains(q) ||
              p.uhid.toLowerCase().contains(q) ||
              p.mobile.toLowerCase().contains(q) ||
              (p.emiratesId?.toLowerCase().contains(q) ?? false);
        }).toList();
      }

      // API uses skip/limit without total meta — infer paging from page size.
      final hasMore = list.length >= perPage;
      final lastPage = hasMore ? page + 1 : page;

      return PaginatedResult(
        data: filtered,
        currentPage: page,
        lastPage: lastPage,
        perPage: perPage,
        total: skip + filtered.length + (hasMore ? 1 : 0),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PatientModel?> getPatientByUhid(String uhid) async {
    try {
      final response = await DioClient.instance.get(
        ApiEndpoints.patient(uhid),
      );
      return PatientModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDio(e);
    }
  }

  Future<PatientModel> createPatient(PatientModel patient) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.patients,
        data: patient.toCreateJson(),
      );
      return PatientModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PatientModel> updatePatient(PatientModel patient) async {
    try {
      final response = await DioClient.instance.put(
        ApiEndpoints.patient(patient.uhid),
        data: patient.toUpdateJson(),
      );
      return PatientModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deletePatient(String uhid) async {
    try {
      await DioClient.instance.delete(ApiEndpoints.patient(uhid));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
