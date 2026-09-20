import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/log_entry.dart';
import '../../models/log_level.dart';

class LogListTile extends StatelessWidget {
  const LogListTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final LogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (entry.isNetwork) return _NetworkTile(entry: entry, onTap: onTap);

    final color = entry.level.color;
    return InkWell(
      onTap: onTap,
      onLongPress: () => _copy(context, entry.detailText),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 3),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _badge(entry.level.shortLabel, color),
                const SizedBox(width: 8),
                Text(
                  entry.timeLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                if (entry.source != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      entry.source!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              entry.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({required this.entry, required this.onTap});

  final LogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = entry.statusCode;
    final statusColor = status == null
        ? Colors.white54
        : (status >= 200 && status < 300
            ? const Color(0xFF66BB6A)
            : (status >= 400
                ? const Color(0xFFEF5350)
                : const Color(0xFFFFA726)));

    return InkWell(
      onTap: onTap,
      onLongPress: () => _copy(context, entry.networkDetailText),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: statusColor, width: 3),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _pill(entry.httpMethod ?? '?', const Color(0xFF42A5F5)),
                const SizedBox(width: 6),
                _pill(status?.toString() ?? '—', statusColor),
                const SizedBox(width: 6),
                _pill(
                  entry.durationMs != null ? '${entry.durationMs}ms' : '—',
                  const Color(0xFFAB47BC),
                ),
                const SizedBox(width: 6),
                _pill(
                  (entry.networkKind ?? 'net').toUpperCase(),
                  const Color(0xFF7E57C2),
                ),
                const Spacer(),
                Text(
                  entry.timeLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.url ?? entry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
            if (entry.responseBody != null || entry.requestBody != null) ...[
              const SizedBox(height: 4),
              Text(
                entry.responseBody != null
                    ? 'Preview: ${entry.responsePreview.replaceAll('\n', ' ')}'
                    : 'Payload: ${entry.payloadPreview.replaceAll('\n', ' ')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

Future<void> _copy(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Log copied'),
      duration: Duration(seconds: 1),
    ),
  );
}
