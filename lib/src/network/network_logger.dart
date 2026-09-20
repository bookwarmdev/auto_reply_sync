import '../core/auto_reply_logger.dart';
import '../models/log_level.dart';
import 'curl_builder.dart';
import 'network_call.dart';
import 'network_kind.dart';

/// One place to record network activity from any stack.
///
/// Easy usage:
/// ```dart
/// NetworkLogger.rest(method: 'GET', url: url, statusCode: 200, ...);
/// dio.interceptors.add(AutoReplyDioInterceptor());
/// final client = LoggingHttpClient();
/// ```
class NetworkLogger {
  NetworkLogger._();

  static void record(NetworkCall call) {
    final level = call.error != null || !call.isSuccess
        ? LogLevel.error
        : (call.statusCode != null && call.statusCode! >= 300
            ? LogLevel.warning
            : LogLevel.info);

    logger.log(
      level,
      call.summary,
      source: 'Network/${call.kind.label}',
      properties: call.toProperties(),
      error: call.error,
    );
  }

  static void rest({
    required String method,
    required String url,
    NetworkStack stack = NetworkStack.custom,
    int? statusCode,
    int? durationMs,
    Map<String, dynamic>? requestHeaders,
    Map<String, dynamic>? responseHeaders,
    Object? requestBody,
    Object? responseBody,
    Object? error,
    String? curl,
    Map<String, dynamic>? extra,
  }) {
    record(
      NetworkCall(
        kind: NetworkKind.rest,
        stack: stack,
        method: method.toUpperCase(),
        url: url,
        statusCode: statusCode,
        durationMs: durationMs,
        requestHeaders: requestHeaders ?? const {},
        responseHeaders: responseHeaders ?? const {},
        requestBody: requestBody,
        responseBody: responseBody,
        error: error,
        curl: curl ??
            buildCurl(
              method: method,
              url: url,
              headers: requestHeaders,
              body: requestBody,
            ),
        extra: extra ?? const {},
      ),
    );
  }

  static void graphql({
    required String operationName,
    required String url,
    String method = 'POST',
    NetworkStack stack = NetworkStack.graphql,
    String? query,
    Map<String, dynamic>? variables,
    int? statusCode,
    int? durationMs,
    Map<String, dynamic>? requestHeaders,
    Object? responseBody,
    Object? error,
    Map<String, dynamic>? extra,
  }) {
    final body = {
      if (query != null) 'query': query,
      if (variables != null) 'variables': variables,
      'operationName': operationName,
    };
    record(
      NetworkCall(
        kind: NetworkKind.graphql,
        stack: stack,
        method: method.toUpperCase(),
        url: url,
        statusCode: statusCode,
        durationMs: durationMs,
        requestHeaders: requestHeaders ?? const {},
        requestBody: body,
        responseBody: responseBody,
        error: error,
        operationName: operationName,
        curl: buildCurl(
          method: method,
          url: url,
          headers: requestHeaders,
          body: body,
        ),
        extra: extra ?? const {},
      ),
    );
  }

  static void grpc({
    required String method,
    required String service,
    int? statusCode,
    int? durationMs,
    Object? requestBody,
    Object? responseBody,
    Object? error,
    Map<String, dynamic>? extra,
  }) {
    record(
      NetworkCall(
        kind: NetworkKind.grpc,
        stack: NetworkStack.grpc,
        method: method,
        url: service,
        statusCode: statusCode,
        durationMs: durationMs,
        requestBody: requestBody,
        responseBody: responseBody,
        error: error,
        operationName: method,
        extra: extra ?? const {},
      ),
    );
  }

  static void websocket({
    required String url,
    required String event,
    Object? payload,
    Object? error,
    NetworkStack stack = NetworkStack.websocket,
    Map<String, dynamic>? extra,
  }) {
    record(
      NetworkCall(
        kind: NetworkKind.websocket,
        stack: stack,
        method: event.toUpperCase(),
        url: url,
        requestBody: payload,
        error: error,
        extra: {
          'event': event,
          ...?extra,
        },
      ),
    );
  }

  static void sse({
    required String url,
    required String event,
    Object? data,
    Object? error,
    int? statusCode,
    Map<String, dynamic>? extra,
  }) {
    record(
      NetworkCall(
        kind: NetworkKind.sse,
        stack: NetworkStack.sse,
        method: 'SSE',
        url: url,
        statusCode: statusCode,
        responseBody: data,
        error: error,
        operationName: event,
        extra: {
          'event': event,
          ...?extra,
        },
      ),
    );
  }
}
