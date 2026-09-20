import '../models/log_level.dart';

class LoggerConfig {
  const LoggerConfig({
    this.enabled = true,
    this.maxEntries = 500,
    this.minLevel = LogLevel.verbose,
    this.mirrorToConsole = true,
  });

  final bool enabled;
  final int maxEntries;
  final LogLevel minLevel;
  final bool mirrorToConsole;

  LoggerConfig copyWith({
    bool? enabled,
    int? maxEntries,
    LogLevel? minLevel,
    bool? mirrorToConsole,
  }) {
    return LoggerConfig(
      enabled: enabled ?? this.enabled,
      maxEntries: maxEntries ?? this.maxEntries,
      minLevel: minLevel ?? this.minLevel,
      mirrorToConsole: mirrorToConsole ?? this.mirrorToConsole,
    );
  }
}
