import 'network_logger.dart';
import 'network_kind.dart';

/// Convenience wrapper for GraphQL clients (graphql_flutter, ferry, etc.).
///
/// Call around your existing execute method — no hard dependency on a GQL package.
class GraphQlNetwork {
  GraphQlNetwork._();

  static Future<T> trace<T>({
    required String operationName,
    required String url,
    required Future<T> Function() execute,
    String? query,
    Map<String, dynamic>? variables,
    Map<String, dynamic>? requestHeaders,
    Object? Function(T result)? responseBody,
    NetworkStack stack = NetworkStack.graphql,
  }) async {
    final started = DateTime.now();
    try {
      final result = await execute();
      NetworkLogger.graphql(
        operationName: operationName,
        url: url,
        query: query,
        variables: variables,
        requestHeaders: requestHeaders,
        responseBody: responseBody?.call(result) ?? result,
        durationMs: DateTime.now().difference(started).inMilliseconds,
        statusCode: 200,
        stack: stack,
      );
      return result;
    } catch (e) {
      NetworkLogger.graphql(
        operationName: operationName,
        url: url,
        query: query,
        variables: variables,
        requestHeaders: requestHeaders,
        error: e,
        durationMs: DateTime.now().difference(started).inMilliseconds,
        stack: stack,
      );
      rethrow;
    }
  }
}
