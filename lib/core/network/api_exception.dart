import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Parses Dio / FastAPI error payloads into a user-facing message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = _normalizeErrorData(error.response?.data);

    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return ApiException(detail, statusCode: status);
      }
      if (detail is List && detail.isNotEmpty) {
        final messages = detail.map((e) {
          if (e is Map) {
            final loc = (e['loc'] as List?)?.join('.') ?? '';
            final msg = e['msg']?.toString() ?? 'Validation error';
            return loc.isEmpty ? msg : '$loc: $msg';
          }
          return e.toString();
        }).join('\n');
        return ApiException(messages, statusCode: status);
      }
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return ApiException(message, statusCode: status);
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        'Connection timed out. Please try again.',
        statusCode: status,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      if (kIsWeb) {
        return const ApiException(
          'Cannot reach API from the browser. '
          'Keep this running: dart run tool/api_proxy.dart '
          '— or use flutter run -d windows.',
        );
      }
      return const ApiException(
        'Unable to reach the server. Check your network connection.',
      );
    }

    if (status == 401) {
      return const ApiException(
        'Session expired. Please sign in again.',
        statusCode: 401,
      );
    }

    return ApiException(
      error.message ?? 'Something went wrong. Please try again.',
      statusCode: status,
    );
  }

  /// Dio may return error bodies as bytes when `ResponseType.bytes` was used.
  static dynamic _normalizeErrorData(dynamic data) {
    if (data is Map || data is String) return data;
    if (data is List<int>) {
      try {
        final decoded = jsonDecode(utf8.decode(data));
        if (decoded is Map) return decoded;
        if (decoded is String) return decoded;
      } catch (_) {}
    }
    return data;
  }

  @override
  String toString() => message;
}
