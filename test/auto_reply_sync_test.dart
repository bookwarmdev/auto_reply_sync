import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    logger.clear();
    logger.configure(const LoggerConfig(enabled: true, mirrorToConsole: false));
    logger.resume();
  });

  test('stores structured entries with levels', () {
    logger.i('hello', source: 'test');
    logger.e('boom', source: 'test', properties: {'code': 42});

    expect(logger.store.length, 2);
    expect(logger.store.entries.first.level, LogLevel.info);
    expect(logger.store.entries.last.properties['code'], 42);
  });

  test('filters by query and level', () {
    logger.d('alpha');
    logger.w('beta warning');
    logger.e('gamma error');

    final warnings = logger.store.filtered(levels: {LogLevel.warning});
    expect(warnings.length, 1);
    expect(warnings.first.message, 'beta warning');

    final q = logger.store.filtered(query: 'gamma');
    expect(q.length, 1);
  });

  test('circular buffer trims oldest', () {
    logger.configure(const LoggerConfig(maxEntries: 3, mirrorToConsole: false));
    for (var i = 0; i < 5; i++) {
      logger.i('n$i');
    }
    expect(logger.store.length, 3);
    expect(logger.store.entries.first.message, 'n2');
  });

  test('pause prevents new entries', () {
    logger.pause();
    logger.i('should not appear');
    expect(logger.store.length, 0);
    logger.resume();
    logger.i('visible');
    expect(logger.store.length, 1);
  });

  test('legacy StartAutoSync maps into store', () {
    StartAutoSync.setAutoSync(
      fileName: 'session',
      contents: {'message': 'api reply', 'id': 1},
    );
    expect(logger.store.length, 1);
    expect(logger.store.entries.first.source, 'session');
  });
}
