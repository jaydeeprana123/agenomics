import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cross-platform helpers for opening or saving PDF reports.
class PdfFileHelper {
  PdfFileHelper._();

  /// Opens a PDF URL: new tab on web, external app / browser on native.
  static Future<void> openPdfUrl(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened) {
      throw Exception('Could not open the PDF URL.');
    }
  }

  /// Web: open in a new tab. Native: download bytes and save locally.
  static Future<String?> openOrDownloadPdfUrl({
    required String url,
    required String fileName,
  }) async {
    if (kIsWeb) {
      await openPdfUrl(url);
      return null;
    }

    final response = await Dio().get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw Exception('Downloaded PDF was empty.');
    }
    return savePdfBytes(
      bytes: Uint8List.fromList(data),
      fileName: fileName,
    );
  }

  /// Saves PDF bytes locally (all platforms, including web download).
  static Future<String?> savePdfBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final safeName = fileName.toLowerCase().endsWith('.pdf')
        ? fileName
        : '$fileName.pdf';
    final baseName =
        safeName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

    final path = await FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );

    return path;
  }

  static String defaultFileName({String? patientName, String? uhid}) {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('-', '')
        .substring(0, 15);
    final label = (uhid != null && uhid.trim().isNotEmpty)
        ? uhid.trim()
        : (patientName != null && patientName.trim().isNotEmpty)
            ? patientName.trim().replaceAll(RegExp(r'\s+'), '_')
            : 'patient';
    return 'pgx_report_${label}_$stamp.pdf';
  }

  static String platformSaveHint(String? savedPath) {
    if (kIsWeb) {
      return 'The PDF has been downloaded in your browser.';
    }
    if (savedPath != null &&
        savedPath.trim().isNotEmpty &&
        !savedPath.toLowerCase().contains('something went wrong')) {
      return 'Saved to $savedPath';
    }
    return 'The PDF has been saved on this device.';
  }
}
