import 'dart:developer';
import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';

class AutoReplySubcViewer extends StatefulWidget {
  // final String logger;
  final Widget body;
  final String autoReplySyncName;

  const AutoReplySubcViewer({
    super.key,
    required this.body,
    // required this.logger,
    required this.autoReplySyncName,
  });

  @override
  State<AutoReplySubcViewer> createState() => _AutoReplySubcViewerState();
}

class _AutoReplySubcViewerState extends State<AutoReplySubcViewer>
    with WidgetsBindingObserver {
  bool _isEngage = false;
  bool _resizer = false;
  double? height;

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
      _initFileInstance();
    } else if (state == AppLifecycleState.paused) {
      StartAutoSync.deleteAutoSync(fileName: widget.autoReplySyncName);
    } else if (state == AppLifecycleState.inactive) {
      StartAutoSync.deleteAutoSync(fileName: widget.autoReplySyncName);
    } else if (state == AppLifecycleState.detached) {
      StartAutoSync.deleteAutoSync(fileName: widget.autoReplySyncName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          onPressed: _inEngage,
          tooltip: 'Auto Reply Sync',
          child: const Icon(Icons.api_sharp),
        ),
      ),
      body: Stack(
        children: [
          widget.body,
          Visibility(
            visible: _isEngage,
            child: Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: const Color.fromARGB(131, 105, 117, 21).withOpacity(0.8),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => setState(() {
                        _resizeARSContiner(context);
                      }),
                      icon: Icon(
                        _resizer == true
                            ? Icons.zoom_out_map
                            : Icons.zoom_in_map,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: StartAutoSync.getAutoSync(
                              fileName: widget.autoReplySyncName,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(snapshot.hasError.toString());
                              } else {
                                return SelectableText(
                                  snapshot.data == null
                                      ? "No recode found"
                                      : snapshot.data.toString(),
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
          )
        ],
      ),
    );
  }
}
