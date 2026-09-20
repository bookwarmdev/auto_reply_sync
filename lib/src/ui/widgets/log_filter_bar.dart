import 'package:flutter/material.dart';

import '../../models/log_level.dart';

class LogFilterBar extends StatelessWidget {
  const LogFilterBar({
    super.key,
    required this.query,
    required this.selectedLevels,
    required this.networkOnly,
    required this.onQueryChanged,
    required this.onToggleLevel,
    required this.onToggleNetworkOnly,
    required this.onClearFilters,
  });

  final String query;
  final Set<LogLevel> selectedLevels;
  final bool networkOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<LogLevel> onToggleLevel;
  final ValueChanged<bool> onToggleNetworkOnly;
  final VoidCallback onClearFilters;

  int get _activeFilterCount =>
      selectedLevels.length + (networkOnly ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: onQueryChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search…',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () => onQueryChanged(''),
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Badge(
            isLabelVisible: _activeFilterCount > 0,
            label: Text('$_activeFilterCount'),
            backgroundColor: const Color(0xFF7E57C2),
            child: IconButton(
              tooltip: 'Filters',
              onPressed: () => _openFilterSheet(context),
              icon: Icon(
                _activeFilterCount > 0
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
                color: _activeFilterCount > 0
                    ? const Color(0xFFB39DDB)
                    : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) {
    var levels = Set<LogLevel>.from(selectedLevels);
    var netOnly = networkOnly;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            levels.clear();
                            netOnly = false;
                            onClearFilters();
                            setSheetState(() {});
                          },
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Category',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          selected: netOnly,
                          label: const Text('Network only'),
                          labelStyle: TextStyle(
                            color: netOnly
                                ? Colors.black
                                : const Color(0xFF7E57C2),
                            fontWeight: FontWeight.bold,
                          ),
                          selectedColor: const Color(0xFF7E57C2),
                          backgroundColor:
                              const Color(0xFF7E57C2).withValues(alpha: 0.15),
                          checkmarkColor: Colors.black,
                          onSelected: (v) {
                            netOnly = v;
                            onToggleNetworkOnly(v);
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Log level',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final level in LogLevel.values)
                          FilterChip(
                            selected: levels.contains(level),
                            label: Text('${level.shortLabel}  ${level.label}'),
                            labelStyle: TextStyle(
                              color: levels.contains(level)
                                  ? Colors.black
                                  : level.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            selectedColor: level.color,
                            backgroundColor:
                                level.color.withValues(alpha: 0.15),
                            checkmarkColor: Colors.black,
                            onSelected: (_) {
                              if (levels.contains(level)) {
                                levels.remove(level);
                              } else {
                                levels.add(level);
                              }
                              onToggleLevel(level);
                              setSheetState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
