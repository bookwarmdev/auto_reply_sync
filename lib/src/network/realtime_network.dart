import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'network_logger.dart';

/// Tiny helpers so WebSocket / SSE are one-liners to instrument.
class RealtimeNetwork {
  RealtimeNetwork._();

  /// Log a WebSocket lifecycle or message event.
  static void ws({
    required String url,
    required String event,
    Object? payload,
    Object? error,
  }) {
    NetworkLogger.websocket(
      url: url,
      event: event,
      payload: payload,
      error: error,
    );
  }

  /// Subscribe to an SSE endpoint and log each event automatically.
  ///
  /// Returns a subscription you can cancel.
  static StreamSubscription<String> listenSse({
    required Uri url,
    Map<String, String>? headers,
    void Function(String raw)? onEvent,
  }) {
    final client = http.Client();
    final controller = StreamController<String>();

    () async {
      try {
        final request = http.Request('GET', url);
        if (headers != null) request.headers.addAll(headers);
        request.headers.putIfAbsent('Accept', () => 'text/event-stream');

        NetworkLogger.sse(url: url.toString(), event: 'open');

        final response = await client.send(request);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          NetworkLogger.sse(
            url: url.toString(),
            event: 'error',
            statusCode: response.statusCode,
            error: Exception('SSE HTTP ${response.statusCode}'),
          );
          await controller.close();
          client.close();
          return;
        }

        var buffer = '';
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          while (buffer.contains('\n\n')) {
            final index = buffer.indexOf('\n\n');
            final raw = buffer.substring(0, index);
            buffer = buffer.substring(index + 2);
            if (raw.trim().isEmpty) continue;

            String event = 'message';
            final dataLines = <String>[];
            for (final line in raw.split('\n')) {
              if (line.startsWith('event:')) {
                event = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                dataLines.add(line.substring(5).trimLeft());
              }
            }
            final data = dataLines.join('\n');
            NetworkLogger.sse(
              url: url.toString(),
              event: event,
              data: data,
              statusCode: response.statusCode,
            );
            onEvent?.call(raw);
            controller.add(raw);
          }
        }
      } catch (e) {
        NetworkLogger.sse(url: url.toString(), event: 'error', error: e);
        controller.addError(e);
      } finally {
        await controller.close();
        client.close();
      }
    }();

    return controller.stream.listen(null);
  }
}
