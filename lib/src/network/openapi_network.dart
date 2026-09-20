import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'dio_network_interceptor.dart';
import 'logging_http_client.dart';
import 'network_kind.dart';

/// First-class OpenAPI / swagger-generated client wiring.
///
/// Generators usually take either a [Dio] or an [http.Client] — pick the matching helper.
///
/// ```dart
/// // openapi-generator Dio client
/// final dio = Dio()..interceptors.add(OpenApiNetwork.dioInterceptor());
/// final api = DefaultApi(dio, serializers);
///
/// // openapi-generator / dart http client
/// final api = DefaultApi(OpenApiNetwork.httpClient());
/// ```
class OpenApiNetwork {
  OpenApiNetwork._();

  static Interceptor dioInterceptor({
    bool logRequestBody = true,
    bool logResponseBody = true,
    int maxBodyLength = 8000,
  }) {
    return AutoReplyDioInterceptor(
      stack: NetworkStack.openapi,
      logRequestBody: logRequestBody,
      logResponseBody: logResponseBody,
      maxBodyLength: maxBodyLength,
    );
  }

  static http.Client httpClient({
    http.Client? inner,
    bool logRequestBody = true,
    bool logResponseBody = true,
    int maxBodyLength = 8000,
  }) {
    return LoggingHttpClient(
      inner: inner,
      stack: NetworkStack.openapi,
      logRequestBody: logRequestBody,
      logResponseBody: logResponseBody,
      maxBodyLength: maxBodyLength,
    );
  }
}
