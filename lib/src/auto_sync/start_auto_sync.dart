import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

class StartAutoSync {
  // StartAutoSync._();

  static Directory? _directory;

  static File _file({required String fileName}) =>
      File("${_directory?.path}/$fileName.txt");

  static Future get instance => _instance();

  static Future _instance() async {
    _directory = await getTemporaryDirectory();
  }

  /// check if the instance is avalable or not
  static Future<bool> _directoryChecker() async {
    await _instance();
    if (_directory == null) {
      throw Exception("No Instance not found.");
    } else {
      return false;
    }
  }

  static void _callBack(dynamic contents, Function(String data) callback) {
    if (contents is Map ||
        contents is Map<String, dynamic> ||
        contents is List ||
        contents is int ||
        contents is double ||
        contents is bool) {
      callback(jsonEncode(contents));
      return;
    } else if (contents is String) {
      callback(contents);
      return;
    } else {
      throw Exception("Unknown object!");
    }
  }

  /// to check if the file as performed any api call
  /// which as save on the file
  static Future<bool> hasAutoSync({required String fileName}) async {
    await _directoryChecker();
    try {
      return _file(fileName: fileName).existsSync();
    } catch (e) {
      log("hasAutoSync $e");
      return false;
    }
  }

  static void deleteAutoSync({required String fileName}) async {
    if (_directory == null) {
      throw Exception("No Instance not found.");
    }
    try {
      bool isExists = _file(fileName: fileName).existsSync();

      if (isExists) {
        log(isExists.toString());
        _file(fileName: fileName).deleteSync();
      }
    } on PlatformException catch (e) {
      if (e.message == "Cannot delete file") {
        log("Can not delete file  $e");
      } else {
        log(e.message.toString());
      }
      return;
    } catch (e) {
      log("deleteAutoSync $e");
      return;
    }
  }

  static void clearAutoSync({required String fileName}) async {
    await _directoryChecker();
    try {
      String contents = "";
      _callBack(contents, (data) {
        _file(fileName: fileName).writeAsStringSync(
          contents,
        );
      });
    } catch (e) {
      log("clearAutoSync $e");
      return;
    }
  }

  static void setAutoSync({
    required String fileName,
    required dynamic contents,
  }) async {
    await _directoryChecker();
    try {
      _callBack(contents, (data) {
        _file(fileName: fileName).writeAsStringSync(
          "$contents\n ============================ \n",
          flush: false,
          mode: FileMode.append,
        );
      });
      getAutoSyncProvider(fileName);
    } catch (e) {
      log("setAutoSync $e");
      return;
    }
  }

  static dynamic getAutoSync({
    required String fileName,
  }) async {
    await _directoryChecker();
    try {
      return _file(fileName: fileName).readAsStringSync();
    } catch (e) {
      log("getAutoSync $e");
      return;
    }
  }
}

final getAutoSyncProvider = StateNotifierProviderFamily<
    FechRecentFileDataNotifier, InputFileDataState, String>(
  (ref, fileName) {
    return FechRecentFileDataNotifier(
      InputFileDataState(fileName: fileName, contents: ""),
    );
  },
);

class InputFileDataState {
  String fileName;
  dynamic contents;

  InputFileDataState({required this.fileName, required this.contents});
}

class FechRecentFileDataNotifier extends StateNotifier<InputFileDataState> {
  // final String fileName;
  FechRecentFileDataNotifier(InputFileDataState inputFileDataState)
      : super(inputFileDataState);

  dynamic getAutoSync(ScrollController scrollController) async {
    await StartAutoSync._directoryChecker();
    try {
      final contents =
          StartAutoSync._file(fileName: state.fileName).readAsStringSync();
      state = InputFileDataState(fileName: state.fileName, contents: contents);
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      // scrollController.animateTo(
      //   scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 100),
      //   curve: Curves.easeInOut,
      // );
      // });
      return contents;
    } catch (e) {
      log("getAutoSync $e");
      return;
    }
  }

  setAutoSync(dynamic contents) async {
    await StartAutoSync._directoryChecker();
    try {
      StartAutoSync._callBack(contents, (data) {
        StartAutoSync._file(fileName: state.fileName).writeAsStringSync(
          "$contents\n ============================ \n",
          flush: false,
          mode: FileMode.append,
        );
      });
    } catch (e) {
      log("setAutoSync $e");
      return;
    }
  }
}
