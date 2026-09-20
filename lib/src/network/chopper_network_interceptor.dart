import 'dart:async';

import 'package:chopper/chopper.dart';

import 'curl_builder.dart';
import 'network_kind.dart';
import 'network_logger.dart';

/// Drop-in Chopper interceptor (Chopper 8+ `Interceptor` API).
///
/// ```dart
/// final chopper = ChopperClient(
///   baseUrl: Uri.parse('https://api.example.com'),
///   interceptors: [AutoReplyChopperInterceptor()],
/// );
/// ```
class AutoReplyChopperInterceptor implements Interceptor {
  AutoReplyChopperInterceptor({
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxBodyLength = 8000,
  });

  final bool logRequestBody;
  final bool logResponseBody;
  final int maxBodyLength;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = chain.request;
    final started = DateTime.now();
    final url = _url(request);
    final method = request.method;
    final requestHeaders = Map<String, dynamic>.from(request.headers);
    final requestBody =
        logRequestBody ? _truncate(_bodyOf(request.body)) : null;

    try {
      final response = await chain.proceed(request);
      final durationMs = DateTime.now().difference(started).inMilliseconds;

      NetworkLogger.rest(
        method: method,
        url: url,
        stack: NetworkStack.chopper,
        statusCode: response.statusCode,
        durationMs: durationMs,
        requestHeaders: requestHeaders,
        responseHeaders: Map<String, dynamic>.from(response.headers),
        requestBody: requestBody,
        responseBody:
            logResponseBody ? _truncate(_bodyOf(response.body)) : null,
        error: response.isSuccessful
            ? null
            : (response.error ?? Exception('HTTP ${response.statusCode}')),
        curl: buildCurl(
          method: method,
          url: url,
          headers: requestHeaders,
          body: request.body,
        ),
      );
      return response;
    } catch (error, stackTrace) {
      NetworkLogger.rest(
        method: method,
        url: url,
        stack: NetworkStack.chopper,
        requestHeaders: requestHeaders,
        requestBody: requestBody,
        error: error,
        durationMs: DateTime.now().difference(started).inMilliseconds,
        curl: buildCurl(
          method: method,
          url: url,
          headers: requestHeaders,
          body: request.body,
        ),
        extra: {'stackTrace': stackTrace.toString()},
      );
      rethrow;
    }
  }

  String _url(Request request) {
    final base = request.baseUri;
    final uri = request.uri;
    if (uri.hasScheme) return uri.toString();
    return base.resolveUri(uri).toString();
  }

  Object? _bodyOf(Object? body) {
    if (body == null) return null;
    return body;
  }

  Object? _truncate(Object? data) {
    if (data == null) return null;
    final text = data is String ? data : data.toString();
    if (text.length <= maxBodyLength) return data is String ? data : data;
    return '${text.substring(0, maxBodyLength)}…';
  }
}

/// Convenience factory matching Retrofit/OpenAPI naming.
class ChopperNetwork {
  ChopperNetwork._();

  static Interceptor interceptor({
    bool logRequestBody = true,
    bool logResponseBody = true,
    int maxBodyLength = 8000,
  }) {
    return AutoReplyChopperInterceptor(
      logRequestBody: logRequestBody,
      logResponseBody: logResponseBody,
      maxBodyLength: maxBodyLength,
    );
  }
}
