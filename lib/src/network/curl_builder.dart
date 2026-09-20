import 'dart:convert';

/// Builds a copy-pasteable cURL command from HTTP-ish call data.
String buildCurl({
  required String method,
  required String url,
  Map<String, dynamic>? headers,
  Object? body,
}) {
  final buffer = StringBuffer("curl -X ${method.toUpperCase()} '${_escape(url)}'");

  headers?.forEach((key, value) {
    if (value == null) return;
    final lower = key.toLowerCase();
    if (lower == 'content-length') return;
    buffer.write(" \\\n  -H '${_escape('$key: $value')}'");
  });

  if (body != null) {
    final payload = body is String ? body : jsonEncode(body);
    buffer.write(" \\\n  --data '${_escape(payload)}'");
  }

  return buffer.toString();
}

String _escape(String input) => input.replaceAll("'", r"'\''");
