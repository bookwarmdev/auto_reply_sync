import '../core/auto_reply_logger.dart';
import '../models/log_level.dart';

/// Legacy API kept for existing call sites.
/// Prefer [AutoReplyLogger] / [logger] for new code.
class StartAutoSync {
  StartAutoSync._();

  /// No-op retained for older init patterns.
  static Future<void> get instance async {}

  static Future<bool> hasAutoSync({required String fileName}) async =>
      logger.store.length > 0;

  static void deleteAutoSync({required String fileName}) => logger.clear();

  static void clearAutoSync({required String fileName}) => logger.clear();

  static void setAutoSync({
    required String fileName,
    required dynamic contents,
  }) {
    logger.event(
      contents,
      level: LogLevel.info,
      source: fileName,
      message: contents is Map && contents['message'] != null
          ? contents['message'].toString()
          : 'auto sync event',
    );
  }

  static Future<String> getAutoSync({required String fileName}) async {
    return logger.exportText();
  }
}
