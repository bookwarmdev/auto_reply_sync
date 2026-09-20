
import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    logger.clear();
    logger.configure(const LoggerConfig(enabled: true, mirrorToConsole: false));
    logger.resume();
  });

  test('NetworkLogger.rest records network category and curl', () {
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://example.com/a',
      stack: NetworkStack.dio,
      statusCode: 200,
      durationMs: 12,
    );
    expect(logger.store.length, 1);
    final entry = logger.store.entries.single;
    expect(entry.isNetwork, isTrue);
    expect(entry.curl, contains('curl -X GET'));
    expect(entry.properties['stack'], 'dio');
  });

  test('networkOnly filter', () {
    logger.i('app log');
    NetworkLogger.websocket(url: 'wss://x', event: 'open');
    expect(logger.store.filtered(networkOnly: true).length, 1);
  });

  test('graphql and grpc helpers', () {
    NetworkLogger.graphql(
      operationName: 'Q',
      url: 'https://gql',
      statusCode: 200,
    );
    NetworkLogger.grpc(method: 'M', service: 'svc');
    expect(logger.store.length, 2);
    expect(logger.store.entries.first.networkKind, 'graphql');
    expect(logger.store.entries.last.networkKind, 'grpc');
  });

  test('buildCurl escapes quotes', () {
    final curl = buildCurl(
      method: 'POST',
      url: "https://x.com?q='1'",
      headers: {'Authorization': "Bearer 'x'"},
      body: {'a': 1},
    );
    expect(curl, contains("curl -X POST"));
    expect(curl, contains('-H'));
    expect(curl, contains('--data'));
  });

  test('network entry exposes headers payload response timing', () {
    NetworkLogger.rest(
      method: 'POST',
      url: 'https://example.com/items',
      stack: NetworkStack.dio,
      statusCode: 201,
      durationMs: 88,
      requestHeaders: {'Content-Type': 'application/json'},
      responseHeaders: {'x-request-id': 'abc'},
      requestBody: {'name': 'Ada'},
      responseBody: {'id': 9, 'name': 'Ada'},
    );
    final e = logger.store.entries.single;
    expect(e.httpMethod, 'POST');
    expect(e.statusCode, 201);
    expect(e.durationMs, 88);
    expect(e.requestHeaders['Content-Type'], 'application/json');
    expect(e.responseHeaders['x-request-id'], 'abc');
    expect(e.requestBody, isA<Map>());
    expect(e.responseBody, isA<Map>());
    expect(e.responsePreview, contains('Ada'));
    expect(e.networkDetailText, contains('Request headers'));
  });
}
