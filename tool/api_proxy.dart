import 'dart:async';
import 'dart:io';

/// Local CORS proxy for Flutter Web development.
///
/// Usage:
///   dart run tool/api_proxy.dart
///
/// Optional:
///   dart run tool/api_proxy.dart https://your-ngrok-url 8090
///
/// Keep this running, then launch the Flutter web app. Web builds call
/// http://localhost:8090 which forwards to the remote API with CORS headers.
Future<void> main(List<String> args) async {
  final targetBase = args.isNotEmpty
      ? args.first
      : 'https://32dd-115-246-26-2.ngrok-free.app';
  final port = args.length > 1 ? int.parse(args[1]) : 8090;

  final targetUri = Uri.parse(targetBase);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  stdout.writeln('AGenomics CORS proxy listening on http://localhost:$port');
  stdout.writeln('Forwarding to $targetBase');
  stdout.writeln('Press Ctrl+C to stop.\n');

  await for (final request in server) {
    unawaited(_handle(request, targetUri));
  }
}

Future<void> _handle(HttpRequest request, Uri targetUri) async {
  _applyCors(request.response);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  HttpClient? client;
  try {
    final upstreamUri = Uri(
      scheme: targetUri.scheme,
      host: targetUri.host,
      port: targetUri.hasPort ? targetUri.port : null,
      path: request.uri.path,
      query: request.uri.hasQuery ? request.uri.query : null,
    );

    client = HttpClient();
    final upstreamRequest = await client.openUrl(request.method, upstreamUri);

    request.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'host' ||
          lower == 'origin' ||
          lower == 'referer' ||
          lower == 'content-length') {
        return;
      }
      for (final value in values) {
        upstreamRequest.headers.add(name, value);
      }
    });
    upstreamRequest.headers.set('ngrok-skip-browser-warning', 'true');
    upstreamRequest.headers.set('Host', targetUri.host);

    await request.forEach(upstreamRequest.add);
    final upstreamResponse = await upstreamRequest.close();

    request.response.statusCode = upstreamResponse.statusCode;
    upstreamResponse.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'transfer-encoding' ||
          lower == 'content-length' ||
          lower.startsWith('access-control-')) {
        return;
      }
      for (final value in values) {
        request.response.headers.add(name, value);
      }
    });
    _applyCors(request.response);

    await request.response.addStream(upstreamResponse);
    await request.response.close();

    stdout.writeln(
      '${request.method} ${request.uri.path} -> ${upstreamResponse.statusCode}',
    );
  } catch (e, st) {
    stderr.writeln('Proxy error: $e\n$st');
    try {
      request.response.statusCode = HttpStatus.badGateway;
      request.response.headers.contentType = ContentType.json;
      _applyCors(request.response);
      request.response.write('{"detail":"Proxy error: $e"}');
      await request.response.close();
    } catch (_) {}
  } finally {
    client?.close(force: true);
  }
}

void _applyCors(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  );
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Authorization, Content-Type, Accept, ngrok-skip-browser-warning',
  );
  response.headers.set('Access-Control-Max-Age', '86400');
}
