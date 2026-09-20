import 'package:dio/dio.dart';

import 'curl_builder.dart';
import 'network_logger.dart';
import 'network_kind.dart';

/// Drop-in Dio interceptor.
///
/// For Retrofit use [RetrofitNetwork.interceptor].
/// For OpenAPI (Dio) use [OpenApiNetwork.dioInterceptor].
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(AutoReplyDioInterceptor());
/// ```
class AutoReplyDioInterceptor extends Interceptor {
  AutoReplyDioInterceptor({
    this.stack = NetworkStack.dio,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.maxBodyLength = 8000,
  });

  final NetworkStack stack;
  final bool logRequestBody;
  final bool logResponseBody;
  final int maxBodyLength;

  static const _startKey = '_ars_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(
      options: response.requestOptions,
      statusCode: response.statusCode,
      responseHeaders: _headers(response.headers.map),
      responseBody: logResponseBody ? _truncate(response.data) : null,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      options: err.requestOptions,
      statusCode: err.response?.statusCode,
      responseHeaders: err.response == null
          ? const {}
          : _headers(err.response!.headers.map),
      responseBody: logResponseBody ? _truncate(err.response?.data) : null,
      error: err,
    );
    handler.next(err);
  }

  void _log({
    required RequestOptions options,
    int? statusCode,
    Map<String, dynamic> responseHeaders = const {},
    Object? responseBody,
    Object? error,
  }) {
    final started = options.extra[_startKey];
    final durationMs = started is DateTime
        ? DateTime.now().difference(started).inMilliseconds
        : null;

    final requestHeaders = <String, dynamic>{
      for (final e in options.headers.entries) e.key: e.value?.toString(),
    };

    NetworkLogger.rest(
      method: options.method,
      url: options.uri.toString(),
      stack: stack,
      statusCode: statusCode,
      durationMs: durationMs,
      requestHeaders: requestHeaders,
      responseHeaders: responseHeaders,
      requestBody: logRequestBody ? _truncate(options.data) : null,
      responseBody: responseBody,
      error: error,
      curl: buildCurl(
        method: options.method,
        url: options.uri.toString(),
        headers: requestHeaders,
        body: options.data,
      ),
      extra: {
        if (options.queryParameters.isNotEmpty)
          'queryParameters': options.queryParameters,
      },
    );
  }

  Map<String, dynamic> _headers(Map<String, List<String>> map) {
    return {
      for (final e in map.entries) e.key: e.value.join(', '),
    };
  }

  Object? _truncate(Object? data) {
    if (data == null) return null;
    final text = data is String ? data : data.toString();
    if (text.length <= maxBodyLength) return data is String ? data : data;
    return '${text.substring(0, maxBodyLength)}…';
  }
}
