import 'dart:convert';

import 'log_level.dart';

/// Structured log event (CLEF-inspired fields for future Seq sinks).
class LogEntry {
  LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.properties = const {},
    this.error,
    this.stackTrace,
  });

  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? source;
  final Map<String, dynamic> properties;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isNetwork => properties['category'] == 'network';

  String? get curl => properties['curl']?.toString();

  String? get networkKind => properties['kind']?.toString();

  String? get networkStack => properties['stack']?.toString();

  String? get httpMethod => properties['method']?.toString();

  String? get url => properties['url']?.toString();

  int? get statusCode {
    final v = properties['statusCode'];
    if (v is int) return v;
    return int.tryParse('$v');
  }

  int? get durationMs {
    final v = properties['durationMs'];
    if (v is int) return v;
    return int.tryParse('$v');
  }

  Map<String, dynamic> get requestHeaders =>
      _asStringKeyedMap(properties['requestHeaders']);

  Map<String, dynamic> get responseHeaders =>
      _asStringKeyedMap(properties['responseHeaders']);

  Object? get requestBody => properties['requestBody'];

  Object? get responseBody => properties['responseBody'];

  String? get operationName => properties['operationName']?.toString();

  String get timeLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  /// Pretty JSON (or plain text) for bodies / maps.
  static String formatValue(Object? value, {int previewChars = 0}) {
    if (value == null) return '—';
    String text;
    if (value is String) {
      final trimmed = value.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          text = const JsonEncoder.withIndent('  ').convert(jsonDecode(trimmed));
        } catch (_) {
          text = value;
        }
      } else {
        text = value;
      }
    } else if (value is Map || value is List) {
      try {
        text = const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        text = value.toString();
      }
    } else {
      text = value.toString();
    }
    if (previewChars > 0 && text.length > previewChars) {
      return '${text.substring(0, previewChars)}…';
    }
    return text;
  }

  String get responsePreview => formatValue(responseBody, previewChars: 400);

  String get payloadPreview => formatValue(requestBody, previewChars: 400);

  /// Compact CLEF-like JSON for export / future Seq ingest.
  Map<String, dynamic> toClef() {
    return {
      '@t': timestamp.toUtc().toIso8601String(),
      '@l': level.label,
      '@m': message,
      if (source != null) 'SourceContext': source,
      if (error != null) '@x': error.toString(),
      if (stackTrace != null) 'StackTrace': stackTrace.toString(),
      ...properties,
    };
  }

  String toClefJson() => jsonEncode(toClef());

  String get detailText {
    if (isNetwork) return networkDetailText;
    final buffer = StringBuffer()
      ..writeln('[$timeLabel] ${level.label}')
      ..writeln(message);
    if (source != null) buffer.writeln('Source: $source');
    if (properties.isNotEmpty) {
      buffer.writeln('Properties:');
      buffer.writeln(const JsonEncoder.withIndent('  ').convert(properties));
    }
    if (error != null) buffer.writeln('Error: $error');
    if (stackTrace != null) buffer.writeln(stackTrace);
    return buffer.toString();
  }

  String get networkDetailText {
    final buffer = StringBuffer()
      ..writeln('${httpMethod ?? ''} ${url ?? ''}'.trim())
      ..writeln('Status: ${statusCode ?? '—'}')
      ..writeln('Duration: ${durationMs != null ? '${durationMs}ms' : '—'}')
      ..writeln('Stack: ${networkStack ?? '—'} / ${networkKind ?? '—'}')
      ..writeln()
      ..writeln('── Request headers ──')
      ..writeln(formatValue(requestHeaders))
      ..writeln()
      ..writeln('── Payload ──')
      ..writeln(formatValue(requestBody))
      ..writeln()
      ..writeln('── Response headers ──')
      ..writeln(formatValue(responseHeaders))
      ..writeln()
      ..writeln('── Response ──')
      ..writeln(formatValue(responseBody));
    if (error != null) {
      buffer.writeln();
      buffer.writeln('── Error ──');
      buffer.writeln(error.toString());
    }
    if (curl != null) {
      buffer.writeln();
      buffer.writeln('── cURL ──');
      buffer.writeln(curl);
    }
    return buffer.toString();
  }

  static Map<String, dynamic> _asStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return const {};
  }
}
