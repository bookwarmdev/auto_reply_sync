import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_sync/encrypt_auto_sync_file.dart';

class AutoReplySubcViewer extends StatefulWidget {
  final Widget body;
  final String autoReplySyncName;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? textStyle;

  const AutoReplySubcViewer({
    super.key,
    required this.body,
    required this.autoReplySyncName,
    this.backgroundColor = Colors.grey,
    this.iconColor = Colors.white,
    this.textStyle,
  });

  @override
  State<AutoReplySubcViewer> createState() => _AutoReplySubcViewerState();
}

class _AutoReplySubcViewerState extends State<AutoReplySubcViewer>
    with WidgetsBindingObserver {
  bool _isEngage = false;
  bool _resizer = false;
  double height = 200.0;

  final ScrollController scrollController = ScrollController();

  _resizeARSContiner(BuildContext context) {
    _resizer = !_resizer;
    if (_resizer == true) {
      height = MediaQuery.of(context).size.height;
    } else {
      height = MediaQuery.of(context).size.height / 3;
    }
  }

  void _inEngage() {
    setState(() {
      _isEngage = !_isEngage;
    });
  }

  _initFileInstance() {
    StartAutoSync.hasAutoSync(fileName: widget.autoReplySyncName);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFileInstance();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await _initFileInstance();
      StartAutoSync.getAutoSync(fileName: widget.autoReplySyncName);
    } else if (state == AppLifecycleState.paused) {
      StartAutoSync.clearAutoSync(fileName: widget.autoReplySyncName);
    } else if (state == AppLifecycleState.inactive) {
      StartAutoSync.clearAutoSync(fileName: widget.autoReplySyncName);
    } else if (state == AppLifecycleState.detached) {
      StartAutoSync.clearAutoSync(fileName: widget.autoReplySyncName);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = getAutoSyncProvider(widget.autoReplySyncName);
    return ProviderScope(
      child: Scaffold(
        floatingActionButton: DraggableFab(
          child: FloatingActionButton(
            onPressed: _inEngage,
            tooltip: 'Auto Reply Sync',
            child: const Icon(
              Icons.api_sharp,
            ),
          ),
        ),
        body: Stack(
          children: [
            widget.body,
            Visibility(
              visible: _isEngage,
              child: GestureDetector(
                onPanStart: (details) {},
                onPanEnd: (details) {},
                onPanUpdate: (details) {},
                onVerticalDragUpdate: (details) {
                  setState(() {
                    height += details.delta.dy;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: height < 100.0 ? 100.0 : height,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor.withOpacity(0.8),
                    border: Border(
                        bottom: BorderSide(
                      color: widget.backgroundColor.withOpacity(0.9),
                      width: 10,
                    )),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => setState(() {
                              StartAutoSync.clearAutoSync(
                                fileName: widget.autoReplySyncName,
                              );
                            }),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Clear Log",
                                style: TextStyle(
                                  color: widget.iconColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            color: widget.iconColor,
                            onPressed: () => setState(() {
                              _resizeARSContiner(context);
                            }),
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                _resizer == true
                                    ? Icons.zoom_out_map
                                    : Icons.zoom_in_map,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final feed = ref.watch(provider);
                              ref
                                  .watch(provider.notifier)
                                  .getAutoSync(scrollController);

                              return Center(
                                child: SelectableText(
                                  feed.contents.toString().isEmpty
                                      ? "No recode found"
                                      : feed.contents,
                                  style: widget.textStyle,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
