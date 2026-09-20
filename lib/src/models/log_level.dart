import 'package:flutter/material.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}

extension LogLevelX on LogLevel {
  String get label {
    switch (this) {
      case LogLevel.verbose:
        return 'VERBOSE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get shortLabel {
    switch (this) {
      case LogLevel.verbose:
        return 'V';
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }

  Color get color {
    switch (this) {
      case LogLevel.verbose:
        return const Color(0xFF9E9E9E);
      case LogLevel.debug:
        return const Color(0xFF42A5F5);
      case LogLevel.info:
        return const Color(0xFF26A69A);
      case LogLevel.warning:
        return const Color(0xFFFFA726);
      case LogLevel.error:
        return const Color(0xFFEF5350);
    }
  }

  int get severity {
    switch (this) {
      case LogLevel.verbose:
        return 0;
      case LogLevel.debug:
        return 1;
      case LogLevel.info:
        return 2;
      case LogLevel.warning:
        return 3;
      case LogLevel.error:
        return 4;
    }
  }
}
