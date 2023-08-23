import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';

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
  double height = 100.0;

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
    return Scaffold(
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
                        IconButton(
                          color: widget.iconColor,
                          onPressed: () => setState(() {
                            StartAutoSync.clearAutoSync(
                              fileName: widget.autoReplySyncName,
                            );
                          }),
                          icon: Text(
                            "Clear Log",
                            style: TextStyle(
                              color: widget.iconColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          color: widget.iconColor,
                          onPressed: () => setState(() {
                            _resizeARSContiner(context);
                          }),
                          icon: Icon(
                            _resizer == true
                                ? Icons.zoom_out_map
                                : Icons.zoom_in_map,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: StartAutoSync.getAutoSync(
                                fileName: widget.autoReplySyncName,
                              ),
                              builder: (context, snapshot) {
                                // _moveToButtom();
                                if (snapshot.hasError) {
                                  return Text(snapshot.hasError.toString());
                                } else {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                  return Center(
                                    child: SelectableText(
                                      snapshot.data == null
                                          ? "No recode found"
                                          : snapshot.data.toString(),
                                      style: widget.textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
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
    );
  }
}
