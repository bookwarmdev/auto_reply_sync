import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/auto_reply_logger.dart';
import '../models/log_entry.dart';
import '../models/log_level.dart';
import 'widgets/log_detail_sheet.dart';
import 'widgets/log_filter_bar.dart';
import 'widgets/log_list_tile.dart';

/// Floating overlay logger (flutter_awesome_logger / DevTools Logging style).
class AutoReplyLoggerViewer extends StatefulWidget {
  const AutoReplyLoggerViewer({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF121212),
    this.fabColor,
    this.initialHeightFraction = 0.4,
    this.showFab = true,
  });

  final Widget child;
  final Color backgroundColor;
  final Color? fabColor;
  final double initialHeightFraction;
  final bool showFab;

  @override
  State<AutoReplyLoggerViewer> createState() => _AutoReplyLoggerViewerState();
}

class _AutoReplyLoggerViewerState extends State<AutoReplyLoggerViewer> {
  bool _open = false;
  bool _expanded = false;
  double _height = 280;
  String _query = '';
  final Set<LogLevel> _levels = {};
  bool _networkOnly = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    logger.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    logger.store.removeListener(_onStoreChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _toggle() => setState(() => _open = !_open);

  void _toggleExpand(BuildContext context) {
    setState(() {
      _expanded = !_expanded;
      final screenH = MediaQuery.sizeOf(context).height;
      _height = _expanded ? screenH * 0.92 : screenH * widget.initialHeightFraction;
    });
  }

  Future<void> _export() async {
    final text = logger.exportText(
      query: _query,
      levels: _levels.isEmpty ? null : _levels,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported logs copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = logger.store.filtered(
      query: _query,
      levels: _levels.isEmpty ? null : _levels,
      networkOnly: _networkOnly,
    );

    return Scaffold(
      floatingActionButton: widget.showFab
          ? DraggableFab(
              child: FloatingActionButton(
                backgroundColor: widget.fabColor,
                onPressed: _toggle,
                tooltip: 'Logger',
                child: Badge(
                  isLabelVisible: logger.store.length > 0,
                  label: Text('${logger.store.length}'),
                  child: Icon(_open ? Icons.close : Icons.terminal),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          widget.child,
          if (_open) _buildPanel(context, entries),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context, List<LogEntry> entries) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            final next = _height - details.delta.dy;
            _height = next.clamp(140.0, MediaQuery.sizeOf(context).height * 0.95);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: _height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
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
              _toolbar(context, entries.length),
              LogFilterBar(
                query: _query,
                selectedLevels: _levels,
                networkOnly: _networkOnly,
                onQueryChanged: (q) => setState(() => _query = q),
                onToggleLevel: (level) {
                  setState(() {
                    if (_levels.contains(level)) {
                      _levels.remove(level);
                    } else {
                      _levels.add(level);
                    }
                  });
                },
                onToggleNetworkOnly: (v) => setState(() => _networkOnly = v),
                onClearFilters: () => setState(() {
                  _query = '';
                  _levels.clear();
                  _networkOnly = false;
                }),
              ),
              const Divider(height: 1, color: Colors.white12),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          logger.store.length == 0
                              ? 'No logs yet'
                              : 'No matching logs',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          // Newest first
                          final entry = entries[entries.length - 1 - index];
                          return LogListTile(
                            entry: entry,
                            onTap: () => showLogDetailSheet(context, entry),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, int visibleCount) {
    final paused = logger.paused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            'Logs ($visibleCount/${logger.store.length})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: paused ? 'Resume' : 'Pause',
            onPressed: () {
              logger.togglePause();
              setState(() {});
            },
            icon: Icon(
              paused ? Icons.play_arrow : Icons.pause,
              color: paused ? Colors.amber : Colors.white70,
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: logger.clear,
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
          ),
          IconButton(
            tooltip: 'Export',
            onPressed: _export,
            icon: const Icon(Icons.copy_all, color: Colors.white70),
          ),
          IconButton(
            tooltip: _expanded ? 'Collapse' : 'Expand',
            onPressed: () => _toggleExpand(context),
            icon: Icon(
              _expanded ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white70,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _toggle,
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Back-compat alias for the old typo name.
typedef AutoReplySubcViewer = AutoReplyLoggerViewerBridge;

/// Adapter so existing `AutoReplySubcViewer(body:, autoReplySyncName:)` still compiles.
class AutoReplyLoggerViewerBridge extends StatelessWidget {
  const AutoReplyLoggerViewerBridge({
    super.key,
    required this.body,
    this.autoReplySyncName = 'autoReplySync',
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.iconColor = Colors.white,
    this.textStyle,
  });

  final Widget body;
  final String autoReplySyncName;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return AutoReplyLoggerViewer(
      backgroundColor: backgroundColor,
      fabColor: iconColor,
      child: body,
    );
  }
}
