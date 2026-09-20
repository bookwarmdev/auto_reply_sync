import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    logger.clear();
    logger.configure(const LoggerConfig(enabled: true, mirrorToConsole: false));
  });

  test('RetrofitNetwork interceptor tags stack as retrofit', () {
    final interceptor = RetrofitNetwork.interceptor();
    expect(interceptor, isA<AutoReplyDioInterceptor>());
    expect((interceptor as AutoReplyDioInterceptor).stack, NetworkStack.retrofit);
  });

  test('OpenApiNetwork helpers tag openapi', () {
    final dio = OpenApiNetwork.dioInterceptor() as AutoReplyDioInterceptor;
    expect(dio.stack, NetworkStack.openapi);
    final client = OpenApiNetwork.httpClient() as LoggingHttpClient;
    expect(client.stack, NetworkStack.openapi);
  });

  test('ChopperNetwork interceptor is AutoReplyChopperInterceptor', () {
    final interceptor = ChopperNetwork.interceptor();
    expect(interceptor, isA<AutoReplyChopperInterceptor>());
  });

  test('named stacks appear in network logs', () {
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://x/retrofit',
      stack: NetworkStack.retrofit,
      statusCode: 200,
    );
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://x/chopper',
      stack: NetworkStack.chopper,
      statusCode: 200,
    );
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://x/openapi',
      stack: NetworkStack.openapi,
      statusCode: 200,
    );
    final stacks = logger.store.entries.map((e) => e.properties['stack']).toList();
    expect(stacks, ['retrofit', 'chopper', 'openapi']);
  });
}
