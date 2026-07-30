import 'dart:convert';
import 'dart:typed_data';

/// Result of `POST /api/v1/integrations/reports/pdf`.
///
/// The OpenAPI schema is an empty object; the API may return JSON metadata,
/// a downloadable URL, or raw PDF bytes depending on server behaviour.
class ReportPdfResult {
  final String? url;
  final Uint8List? bytes;
  final String? message;
  final String? reportType;
  final Map<String, dynamic>? rawJson;

  const ReportPdfResult({
    this.url,
    this.bytes,
    this.message,
    this.reportType,
    this.rawJson,
  });

  bool get hasPdfUrl => url != null && url!.trim().isNotEmpty;
  bool get hasPdfBytes => bytes != null && bytes!.isNotEmpty;

  factory ReportPdfResult.fromJson(Map<String, dynamic> json) {
    String? pickUrl(Map<String, dynamic> map) {
      for (final key in [
        'url',
        'pdf_url',
        'download_url',
        'file_url',
        'report_url',
        'signed_url',
      ]) {
        final value = map[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }

      final data = map['data'];
      if (data is Map) {
        return pickUrl(Map<String, dynamic>.from(data));
      }
      return null;
    }

    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    return ReportPdfResult(
      url: pickUrl(json),
      message: pickString(['message', 'detail', 'status', 'summary']),
      reportType: pickString([
        'report_type',
        'type',
        'detected_type',
        'source_format',
      ]),
      rawJson: json,
    );
  }

  factory ReportPdfResult.fromBytes(Uint8List bytes) {
    return ReportPdfResult(bytes: bytes);
  }

  static bool looksLikePdf(List<int> bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46 && // F
        bytes[4] == 0x2D; // -
  }

  static Map<String, dynamic>? tryDecodeJson(List<int> bytes) {
    try {
      final text = utf8.decode(bytes);
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }
}
