import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Log {
  Log._();

  static bool _logEnabled = true;
  static bool _writeToFile = false;

  static final Queue<FutureOr<void> Function()> _queue =
      Queue<FutureOr<void> Function()>();
  static bool _draining = false;
  static Completer<void>? _flushCompleter;

  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  @visibleForTesting
  static void Function(String message) printer = (message) {
    debugPrint(message);
  };

  /// Formats an ISO-8601-like local timestamp like `2024-05-30T14:30:00.000+08:00`.
  static String formatDateTimeWithTimeZone(DateTime dateTime) {
    final formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime);
    final offset = dateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '$formatted$sign$hours:$minutes';
  }

  static Future<void> init({
    bool enable = true,
    bool writeToFile = false,
  }) async {
    _logEnabled = enable;
    _writeToFile = writeToFile;
  }

  /// Waits for all queued logs (console + file) to finish.
  static Future<void> flush() {
    if (!_draining && _queue.isEmpty) {
      return Future<void>.value();
    }
    _flushCompleter ??= Completer<void>();
    return _flushCompleter!.future;
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
    final createdAt = now();
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
        break;
      case LogLevel.INFO:
        start = green;
        break;
      case LogLevel.WARNING:
        start = yellow;
        break;
      case LogLevel.ERROR:
        start = red;
        break;
    }
    String logStr = '[${level.name}] [$tag] : $content';
    final datetimeStr = formatDateTimeWithTimeZone(createdAt);
    String printStr;
    if (Platform.isAndroid) {
      printStr = '$start$datetimeStr $logStr$end';
    } else {
      printStr = '$datetimeStr $logStr';
    }
    final fileStr = '> $datetimeStr $logStr';

    _enqueue(() async {
      printer(printStr);
      if (_writeToFile) {
        await outputToFile(fileStr, at: createdAt);
      }
    });
  }

  static void _enqueue(FutureOr<void> Function() task) {
    _queue.add(task);
    if (_draining) {
      return;
    }
    _draining = true;
    // Intentionally not awaited: starts executing synchronously until first await.
    // ignore: unawaited_futures
    _drain();
  }

  static Future<void> _drain() async {
    try {
      while (_queue.isNotEmpty) {
        final task = _queue.removeFirst();
        try {
          await Future<void>.sync(task);
        } catch (e, st) {
          log('Log task failed: $e\n$st');
        }
      }
    } finally {
      _draining = false;
      if (_queue.isEmpty) {
        _flushCompleter?.complete();
        _flushCompleter = null;
      }
    }
  }

  static Future<void> outputToFile(String message, {DateTime? at}) async {
    final logFile = await getLogFile(at: at);
    final length = await logFile.length();
    final prefix = length == 0 ? '' : '\n';
    await logFile.writeAsString(
      '$prefix$message',
      mode: FileMode.append,
      flush: true,
    );
  }

  static Future<File> getLogFile({DateTime? at}) async {
    final Directory tempDir = await getLogDir();
    final ts = at ?? now();
    final file =
        File('${tempDir.path}/${DateFormat('yyyyMMdd').format(ts)}.log');
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
