import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class StartAutoSync {
  StartAutoSync._();

  static Directory? _directory;

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
      final file = File("${_directory?.path}/$fileName");
      log("message ${file.path}");
      return file.existsSync();
    } catch (e) {
      log("hasAutoSync $e");
      return false;
    }
  }

  static void deleteAutoSync({required String fileName}) async {
    // await _directoryChecker();
    if (_directory == null) {
      throw Exception("No Instance not found.");
    }
    try {
      final file = File("${_directory?.path}/$fileName");
      file.deleteSync();
    } on PlatformException catch (e) {
      log(e.message.toString());
      return;
    } catch (e) {
      log("deleteAutoSync $e");
      return;
    }
  }

  static void setAutoSync(
      {required String fileName, required dynamic contents}) async {
    await _directoryChecker();
    try {
      _callBack(contents, (data) {
        final file = File("${_directory?.path}/$fileName");
        file.writeAsStringSync(
          "$contents\n",
          flush: false,
          mode: FileMode.append,
        );
      });
    } catch (e) {
      log("setAutoSync $e");
      return;
    }
  }

  static dynamic getAutoSync({required String fileName}) async {
    await _directoryChecker();
    try {
      final file = File('${_directory!.path}/$fileName');
      return file.readAsStringSync();
    } catch (e) {
      log("getAutoSync $e");
      return;
    }
  }
}
