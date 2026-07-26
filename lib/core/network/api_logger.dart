import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Shared logger for all Dio API traffic.
/// Prints only in debug / profile (not release).
class ApiLogger {
  ApiLogger._();

  static const String _tag = 'API';
  static const int _maxBodyLength = 4000;

  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('┌────────────── $_tag REQUEST ──────────────')
      ..writeln('│ ${options.method} ${options.uri}')
      ..writeln('│ Headers: ${_sanitizeHeaders(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${options.queryParameters}');
    }

    final body = _formatBody(options.data);
    if (body != null) {
      buffer.writeln('│ Body: $body');
    }

    buffer.writeln('└──────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logResponse(Response response) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('┌────────────── $_tag RESPONSE ─────────────')
      ..writeln(
        '│ ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
      );

    final body = _formatBody(response.data);
    if (body != null) {
      buffer.writeln('│ Body: $body');
    }

    buffer.writeln('└──────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  static void logError(DioException error) {
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..writeln('┌────────────── $_tag ERROR ────────────────')
      ..writeln(
        '│ ${error.requestOptions.method} ${error.requestOptions.uri}',
      )
      ..writeln('│ Type: ${error.type}')
      ..writeln('│ Status: ${error.response?.statusCode ?? 'n/a'}')
      ..writeln('│ Message: ${error.message}');

    final body = _formatBody(error.response?.data);
    if (body != null) {
      buffer.writeln('│ Body: $body');
    }

    buffer.writeln('└──────────────────────────────────────────');
    debugPrint(buffer.toString());
  }

  /// Masks sensitive auth headers before printing.
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    for (final key in sanitized.keys.toList()) {
      final lower = key.toLowerCase();
      if (lower == 'authorization' || lower == 'cookie') {
        final value = sanitized[key]?.toString() ?? '';
        sanitized[key] = value.length > 16
            ? '${value.substring(0, 12)}…[redacted]'
            : '[redacted]';
      }
    }
    return sanitized;
  }

  static String? _formatBody(dynamic data) {
    if (data == null) return null;

    try {
      if (data is FormData) {
        final fields = data.fields.map((e) => '${e.key}=${e.value}').join(', ');
        final files = data.files.map((e) => e.key).join(', ');
        return 'FormData(fields: {$fields}, files: [$files])';
      }

      if (data is Map || data is List) {
        return _truncate(const JsonEncoder.withIndent('  ').convert(data));
      }

      if (data is String) {
        if (data.isEmpty) return null;
        // Try pretty-print JSON strings.
        try {
          final decoded = jsonDecode(data);
          return _truncate(
            const JsonEncoder.withIndent('  ').convert(decoded),
          );
        } catch (_) {
          return _truncate(data);
        }
      }

      return _truncate(data.toString());
    } catch (_) {
      return _truncate(data.toString());
    }
  }

  static String _truncate(String value) {
    if (value.length <= _maxBodyLength) return value;
    return '${value.substring(0, _maxBodyLength)}… [truncated ${value.length - _maxBodyLength} chars]';
  }
}
