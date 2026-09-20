import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';
import '../models/log_level.dart';
import 'logger_config.dart';

/// In-memory circular buffer of log events.
class LoggerStore extends ChangeNotifier {
  LoggerStore({LoggerConfig config = const LoggerConfig()}) : _config = config;

  LoggerConfig _config;
  final List<LogEntry> _entries = <LogEntry>[];
  bool _paused = false;
  int _idSeq = 0;

  LoggerConfig get config => _config;
  bool get paused => _paused;
  bool get enabled => _config.enabled;
  List<LogEntry> get entries => List.unmodifiable(_entries);
  int get length => _entries.length;

  void updateConfig(LoggerConfig config) {
    _config = config;
    _trim();
    notifyListeners();
  }

  void setPaused(bool value) {
    if (_paused == value) return;
    _paused = value;
    notifyListeners();
  }

  void togglePaused() => setPaused(!_paused);

  LogEntry? add({
    required LogLevel level,
    required String message,
    String? source,
    Map<String, dynamic>? properties,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_config.enabled || _paused) return null;
    if (level.severity < _config.minLevel.severity) return null;

    final entry = LogEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_idSeq++}',
      timestamp: DateTime.now(),
      level: level,
      message: message,
      source: source,
      properties: properties ?? const {},
      error: error,
      stackTrace: stackTrace,
    );

    _entries.add(entry);
    _trim();
    notifyListeners();
    return entry;
  }

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  List<LogEntry> filtered({
    String query = '',
    Set<LogLevel>? levels,
    String? source,
    bool networkOnly = false,
  }) {
    final q = query.trim().toLowerCase();
    return _entries.where((e) {
      if (networkOnly && !e.isNetwork) return false;
      if (levels != null && levels.isNotEmpty && !levels.contains(e.level)) {
        return false;
      }
      if (source != null && source.isNotEmpty && e.source != source) {
        return false;
      }
      if (q.isEmpty) return true;
      return e.message.toLowerCase().contains(q) ||
          (e.source?.toLowerCase().contains(q) ?? false) ||
          e.level.label.toLowerCase().contains(q) ||
          e.properties.values.any(
            (v) => v.toString().toLowerCase().contains(q),
          );
    }).toList(growable: false);
  }

  Set<String> get sources {
    return _entries
        .map((e) => e.source)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  void _trim() {
    final max = _config.maxEntries;
    if (max <= 0) return;
    while (_entries.length > max) {
      _entries.removeAt(0);
    }
  }
}
