import 'dart:convert';
import 'dart:developer' as developer;

import '../models/log_entry.dart';
import '../models/log_level.dart';
import 'logger_config.dart';
import 'logger_store.dart';

/// Global logger facade — write structured events into [store].
class AutoReplyLogger {
  AutoReplyLogger._();

  static final AutoReplyLogger instance = AutoReplyLogger._();

  final LoggerStore store = LoggerStore();

  void configure(LoggerConfig config) => store.updateConfig(config);

  bool get enabled => store.enabled;
  bool get paused => store.paused;

  void pause() => store.setPaused(true);
  void resume() => store.setPaused(false);
  void togglePause() => store.togglePaused();
  void clear() => store.clear();

  void v(
    String message, {
    String? source,
    Map<String, dynamic>? properties,
  }) =>
      log(LogLevel.verbose, message, source: source, properties: properties);

  void d(
    String message, {
    String? source,
    Map<String, dynamic>? properties,
  }) =>
      log(LogLevel.debug, message, source: source, properties: properties);

  void i(
    String message, {
    String? source,
    Map<String, dynamic>? properties,
  }) =>
      log(LogLevel.info, message, source: source, properties: properties);

  void w(
    String message, {
    String? source,
    Map<String, dynamic>? properties,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.warning,
        message,
        source: source,
        properties: properties,
        error: error,
        stackTrace: stackTrace,
      );

  void e(
    String message, {
    String? source,
    Map<String, dynamic>? properties,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.error,
        message,
        source: source,
        properties: properties,
        error: error,
        stackTrace: stackTrace,
      );

  /// Log arbitrary payload (Map/List/String) as structured properties.
  void event(
    dynamic contents, {
    LogLevel level = LogLevel.info,
    String? source,
    String? message,
  }) {
    if (contents is Map<String, dynamic>) {
      log(
        level,
        message ?? contents['message']?.toString() ?? 'event',
        source: source ?? contents['source']?.toString(),
        properties: Map<String, dynamic>.from(contents),
      );
      return;
    }
    if (contents is Map) {
      final map = contents.map((k, v) => MapEntry(k.toString(), v));
      log(
        level,
        message ?? 'event',
        source: source,
        properties: map,
      );
      return;
    }
    if (contents is List) {
      log(
        level,
        message ?? 'list event',
        source: source,
        properties: {'items': contents},
      );
      return;
    }
    log(level, message ?? contents.toString(), source: source);
  }

  LogEntry? log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? properties,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = store.add(
      level: level,
      message: message,
      source: source,
      properties: properties,
      error: error,
      stackTrace: stackTrace,
    );

    if (entry != null && store.config.mirrorToConsole) {
      developer.log(
        _consoleLine(entry),
        name: source ?? 'auto_reply_sync',
        level: _developerLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
    return entry;
  }

  String exportClef({
    String query = '',
    Set<LogLevel>? levels,
  }) {
    final rows = store.filtered(query: query, levels: levels);
    return rows.map((e) => e.toClefJson()).join('\n');
  }

  String exportText({
    String query = '',
    Set<LogLevel>? levels,
  }) {
    final rows = store.filtered(query: query, levels: levels);
    return rows.map((e) => e.detailText).join('\n---\n');
  }

  String _consoleLine(LogEntry entry) {
    final props = entry.properties.isEmpty
        ? ''
        : ' ${jsonEncode(entry.properties)}';
    final src = entry.source == null ? '' : ' [${entry.source}]';
    return '${entry.level.shortLabel}$src ${entry.message}$props';
  }

  int _developerLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

/// Shorthand global accessor.
final logger = AutoReplyLogger.instance;
