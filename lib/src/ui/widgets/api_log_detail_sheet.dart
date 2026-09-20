import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/log_entry.dart';

Future<void> showApiLogDetailSheet(BuildContext context, LogEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _ApiLogDetailSheet(entry: entry),
  );
}

class _ApiLogDetailSheet extends StatelessWidget {
  const _ApiLogDetailSheet({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final status = entry.statusCode;
    final statusColor = status == null
        ? Colors.white54
        : (status >= 200 && status < 300
            ? const Color(0xFF66BB6A)
            : (status >= 400 ? const Color(0xFFEF5350) : const Color(0xFFFFA726)));

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _chip(
                              entry.httpMethod ?? '?',
                              const Color(0xFF42A5F5),
                            ),
                            _chip(status?.toString() ?? '—', statusColor),
                            _chip(
                              entry.durationMs != null
                                  ? '${entry.durationMs}ms'
                                  : '—',
                              const Color(0xFFAB47BC),
                            ),
                            if (entry.networkStack != null)
                              _chip(
                                entry.networkStack!,
                                const Color(0xFF78909C),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          entry.url ?? entry.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.curl != null)
                    IconButton(
                      tooltip: 'Copy cURL',
                      onPressed: () => _copy(context, entry.curl!, 'cURL'),
                      icon: const Icon(Icons.terminal, color: Colors.white70),
                    ),
                  IconButton(
                    tooltip: 'Copy all',
                    onPressed: () =>
                        _copy(context, entry.networkDetailText, 'Log'),
                    icon: const Icon(Icons.copy, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Color(0xFF7E57C2),
              tabs: [
                Tab(text: 'Timing'),
                Tab(text: 'Headers'),
                Tab(text: 'Payload'),
                Tab(text: 'Preview'),
                Tab(text: 'Response'),
              ],
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: TabBarView(
                children: [
                  _TimingTab(entry: entry),
                  _HeadersTab(entry: entry),
                  _CodeTab(
                    title: 'Request payload',
                    value: entry.requestBody,
                    empty: 'No request payload',
                    onCopy: (text) => _copy(context, text, 'Payload'),
                  ),
                  _CodeTab(
                    title: 'Response preview',
                    value: entry.responseBody,
                    empty: 'No response body',
                    previewChars: 400,
                    onCopy: (text) => _copy(context, text, 'Preview'),
                  ),
                  _CodeTab(
                    title: 'Full response',
                    value: entry.responseBody,
                    empty: 'No response body',
                    onCopy: (text) => _copy(context, text, 'Response'),
                    footer: entry.error == null
                        ? null
                        : 'Error: ${entry.error}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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

  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }
}

class _TimingTab extends StatelessWidget {
  const _TimingTab({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Started', entry.timeLabel),
      MapEntry(
        'Duration',
        entry.durationMs != null ? '${entry.durationMs} ms' : '—',
      ),
      MapEntry('Method', entry.httpMethod ?? '—'),
      MapEntry('URL', entry.url ?? '—'),
      MapEntry('Status', entry.statusCode?.toString() ?? '—'),
      MapEntry('Kind', entry.networkKind ?? '—'),
      MapEntry('Stack', entry.networkStack ?? '—'),
      if (entry.operationName != null)
        MapEntry('Operation', entry.operationName!),
      if (entry.error != null) MapEntry('Error', entry.error.toString()),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final row in rows) ...[
          Text(
            row.key,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            row.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _HeadersTab extends StatelessWidget {
  const _HeadersTab({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderBlock(title: 'Request headers', headers: entry.requestHeaders),
        const SizedBox(height: 16),
        _HeaderBlock(title: 'Response headers', headers: entry.responseHeaders),
      ],
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.title, required this.headers});

  final String title;
  final Map<String, dynamic> headers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (headers.isEmpty)
          Text(
            'No headers',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              headers.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
      ],
    );
  }
}

class _CodeTab extends StatelessWidget {
  const _CodeTab({
    required this.title,
    required this.value,
    required this.empty,
    required this.onCopy,
    this.previewChars = 0,
    this.footer,
  });

  final String title;
  final Object? value;
  final String empty;
  final ValueChanged<String> onCopy;
  final int previewChars;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? empty
        : LogEntry.formatValue(value, previewChars: previewChars);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (value != null)
              TextButton.icon(
                onPressed: () => onCopy(LogEntry.formatValue(value)),
                icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                label: const Text('Copy'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            text,
            style: TextStyle(
              color: value == null
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white,
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 12),
          Text(
            footer!,
            style: const TextStyle(color: Color(0xFFEF5350), fontSize: 13),
          ),
        ],
      ],
    );
  }
}
