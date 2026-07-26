import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/storage_service.dart';
import '../models/user_model.dart';

/// Auth repository — OAuth2 password login against `/api/v1/auth/login`.
class AuthRepository {
  static const String demoUsername = 'admin@dch.com';
  static const String demoPassword = 'hadmin123';

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await DioClient.instance.post(
        ApiEndpoints.login,
        data: {
          'username': username.trim(),
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final accessToken = data['access_token']?.toString();
      final refreshToken = data['refresh_token']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        throw const ApiException('Login succeeded but no access token was returned.');
      }

      await StorageService.saveToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await StorageService.saveRefreshToken(refreshToken);
      }

      final user = UserModel(
        id: username.trim(),
        username: username.trim(),
        name: _displayNameFromUsername(username.trim()),
        email: username.trim(),
        role: 'hospital_admin',
      );
      await StorageService.saveUser(user.toJson());
      await StorageService.setLoggedIn(true);

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout() async {
    await StorageService.clearAuth();
  }

  UserModel? getCurrentUser() {
    final data = StorageService.user;
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  bool get isLoggedIn => StorageService.isLoggedIn;

  String _displayNameFromUsername(String username) {
    final local = username.contains('@') ? username.split('@').first : username;
    if (local.isEmpty) return 'Admin';
    return local[0].toUpperCase() + local.substring(1);
  }
}
