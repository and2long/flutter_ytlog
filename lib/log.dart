import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Log {
  Log._();

  static bool _logEnabled = true;
  static bool _writeToFile = false;

  static Future<void> init({
    bool enable = true,
    bool writeToFile = false,
  }) async {
    _logEnabled = enable;
    _writeToFile = writeToFile;
  }

  static void d(String tag, Object? content) {
    mPrint(LogLevel.DEBUG, tag, content.toString());
  }

  static void i(String tag, Object? content) {
    mPrint(LogLevel.INFO, tag, content.toString());
  }

  static void w(String tag, Object? content) {
    mPrint(LogLevel.WARNING, tag, content.toString());
  }

  static void e(String tag, Object? content) {
    mPrint(LogLevel.ERROR, tag, content.toString());
  }

  static void mPrint(LogLevel level, String tag, String content) {
    if (!_logEnabled) {
      return;
    }
    // 终端颜色：https://zhuanlan.zhihu.com/p/634706318
    var start = '\x1b[90m';
    const end = '\x1b[0m';

    // const white = '\x1b[37m';
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const blue = '\x1B[34m';

    switch (level) {
      case LogLevel.DEBUG:
        start = blue;
      case LogLevel.INFO:
        start = green;
      case LogLevel.WARNING:
        start = yellow;
      case LogLevel.ERROR:
        start = red;
    }
    String logStr = '[${level.name}] [$tag] : $content';
    String datetimeStr = '${DateTime.now()} ';
    String printStr = '$start$datetimeStr$logStr$end';
    if (Platform.isIOS) {
      /// Color codes in error messages are probably escaped when using the iOS simulator
      /// https://github.com/flutter/flutter/issues/20663
      log(printStr);
    } else {
      debugPrint(printStr);
    }
    if (_writeToFile) {
      outputToFile('> ${DateTime.now()} $logStr');
    }
  }

  static outputToFile(String message) async {
    File logFile = await getLogFile();
    int length = await logFile.length();
    if (length == 0) {
      logFile.writeAsStringSync(
        message,
        mode: FileMode.write,
      );
    } else {
      logFile.writeAsStringSync(
        '\n$message',
        mode: FileMode.append,
      );
    }
  }

  static Future<File> getLogFile() async {
    final Directory tempDir = await getLogDir();
    final file = File(
        '${tempDir.path}/${DateFormat('yyyyMMdd').format(DateTime.now())}.log');
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  static Future<Directory> getLogDir() async {
    final Directory tempDir = Platform.isAndroid
        ? (await getExternalCacheDirectories())!.first
        : await getApplicationDocumentsDirectory();
    return tempDir;
  }
}

// ignore: constant_identifier_names
enum LogLevel { DEBUG, INFO, WARNING, ERROR }
