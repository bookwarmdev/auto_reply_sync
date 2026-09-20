import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'curl_builder.dart';
import 'network_kind.dart';
import 'network_logger.dart';

/// Drop-in [http.Client] wrapper — use for raw `http`, Chopper (http), OpenAPI generators on http.
///
/// ```dart
/// final client = LoggingHttpClient();
/// final res = await client.get(Uri.parse('https://example.com'));
/// ```
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient({
    http.Client? inner,
    this.stack = NetworkStack.http,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxBodyLength = 8000,
  }) : _inner = inner ?? http.Client();

  final http.Client _inner;
  final NetworkStack stack;
  final bool logRequestBody;
  final bool logResponseBody;
  final int maxBodyLength;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final started = DateTime.now();
    Object? requestBody;
    if (logRequestBody && request is http.Request) {
      requestBody = _truncate(request.body);
    }

    try {
      final streamed = await _inner.send(request);
      final bytes = await streamed.stream.toBytes();
      final body = utf8.decode(bytes, allowMalformed: true);
      final durationMs = DateTime.now().difference(started).inMilliseconds;

      NetworkLogger.rest(
        method: request.method,
        url: request.url.toString(),
        stack: stack,
        statusCode: streamed.statusCode,
        durationMs: durationMs,
        requestHeaders: Map<String, dynamic>.from(request.headers),
        responseHeaders: Map<String, dynamic>.from(streamed.headers),
        requestBody: requestBody,
        responseBody: logResponseBody ? _truncate(body) : null,
        curl: buildCurl(
          method: request.method,
          url: request.url.toString(),
          headers: request.headers,
          body: request is http.Request ? request.body : null,
        ),
      );

      return http.StreamedResponse(
        Stream<List<int>>.value(bytes),
        streamed.statusCode,
        contentLength: bytes.length,
        request: streamed.request,
        headers: streamed.headers,
        reasonPhrase: streamed.reasonPhrase,
        isRedirect: streamed.isRedirect,
        persistentConnection: streamed.persistentConnection,
      );
    } catch (error, stackTrace) {
      NetworkLogger.rest(
        method: request.method,
        url: request.url.toString(),
        stack: stack,
        requestHeaders: Map<String, dynamic>.from(request.headers),
        requestBody: requestBody,
        error: error,
        durationMs: DateTime.now().difference(started).inMilliseconds,
        curl: buildCurl(
          method: request.method,
          url: request.url.toString(),
          headers: request.headers,
          body: request is http.Request ? request.body : null,
        ),
        extra: {'stackTrace': stackTrace.toString()},
      );
      rethrow;
    }
  }

  @override
  void close() => _inner.close();

  Object? _truncate(Object? data) {
    if (data == null) return null;
    final text = data.toString();
    if (text.length <= maxBodyLength) return data;
    return '${text.substring(0, maxBodyLength)}…';
  }
}
