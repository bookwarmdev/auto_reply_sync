import 'package:dio/dio.dart';

import 'dio_network_interceptor.dart';
import 'network_kind.dart';

/// First-class Retrofit wiring (`package:retrofit` is Dio-based).
///
/// ```dart
/// final dio = Dio()..interceptors.add(RetrofitNetwork.interceptor());
/// final api = RestClient(dio); // generated retrofit client
/// ```
class RetrofitNetwork {
  RetrofitNetwork._();

  /// Drop-in interceptor tagged as [NetworkStack.retrofit].
  static Interceptor interceptor({
    bool logRequestBody = true,
    bool logResponseBody = true,
    int maxBodyLength = 8000,
  }) {
    return AutoReplyDioInterceptor(
      stack: NetworkStack.retrofit,
      logRequestBody: logRequestBody,
      logResponseBody: logResponseBody,
      maxBodyLength: maxBodyLength,
    );
  }
}
