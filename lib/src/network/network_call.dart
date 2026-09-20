import 'network_kind.dart';

/// Normalized network event shared by all adapters.
class NetworkCall {
  const NetworkCall({
    required this.kind,
    required this.stack,
    required this.method,
    required this.url,
    this.statusCode,
    this.durationMs,
    this.requestHeaders = const {},
    this.responseHeaders = const {},
    this.requestBody,
    this.responseBody,
    this.error,
    this.operationName,
    this.curl,
    this.extra = const {},
  });

  final NetworkKind kind;
  final NetworkStack stack;
  final String method;
  final String url;
  final int? statusCode;
  final int? durationMs;
  final Map<String, dynamic> requestHeaders;
  final Map<String, dynamic> responseHeaders;
  final Object? requestBody;
  final Object? responseBody;
  final Object? error;
  final String? operationName;
  final String? curl;
  final Map<String, dynamic> extra;

  bool get isSuccess {
    if (error != null) return false;
    if (statusCode == null) return true;
    return statusCode! >= 200 && statusCode! < 400;
  }

  String get summary {
    final status = statusCode == null ? '' : ' → $statusCode';
    final ms = durationMs == null ? '' : ' (${durationMs}ms)';
    final op = operationName == null ? '' : ' $operationName';
    return '${kind.label} $method$op $url$status$ms';
  }

  Map<String, dynamic> toProperties() {
    return {
      'category': 'network',
      'kind': kind.name,
      'stack': stack.name,
      'method': method,
      'url': url,
      if (statusCode != null) 'statusCode': statusCode,
      if (durationMs != null) 'durationMs': durationMs,
      if (operationName != null) 'operationName': operationName,
      if (requestHeaders.isNotEmpty) 'requestHeaders': requestHeaders,
      if (responseHeaders.isNotEmpty) 'responseHeaders': responseHeaders,
      if (requestBody != null) 'requestBody': _safe(requestBody),
      if (responseBody != null) 'responseBody': _safe(responseBody),
      if (curl != null) 'curl': curl,
      if (error != null) 'error': error.toString(),
      ...extra,
    };
  }

  static Object? _safe(Object? value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is Map || value is List) return value;
    return value.toString();
  }
}
