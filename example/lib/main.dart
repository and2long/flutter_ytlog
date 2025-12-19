import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ytlog/flutter_ytlog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Log.init(
    enable: true,
    writeToFile: true,
    // Force ANSI color on/off if you want:
    // ansiColor: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_ytlog example',
      home: const LogDemoPage(),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}

class LogDemoPage extends StatefulWidget {
  const LogDemoPage({super.key});

  @override
  State<LogDemoPage> createState() => _LogDemoPageState();
}

class _LogDemoPageState extends State<LogDemoPage> {
  String _status = 'Ready';

  void _logAllLevels() {
    Log.d('DEMO', 'Debug message');
    Log.i('DEMO', 'Info message');
    Log.w('DEMO', 'Warning message');
    Log.e('DEMO', 'Error message');

    setState(() => _status = 'Logged 4 lines');
  }

  Future<void> _logBurst() async {
    // Intentionally alternates short/long messages so you can visually verify
    // whether the console output ordering stays correct when long logs are
    // chunked by the underlying platform.
    const pairs = 10;
    const longChars = 500;
    final longPayload = List.filled(longChars, 'A').join();

    setState(() => _status = 'Logging $pairs short/long pairs...');

    for (var i = 0; i < pairs; i++) {
      Log.d('BURST', 'S[$i] short');
      Log.i('BURST', 'L[$i] long start: $longPayload');
    }

    await Log.flush();
    setState(() => _status = 'Flushed $pairs short/long pairs');
  }

  Future<void> _flush() async {
    setState(() => _status = 'Flushing...');
    await Log.flush();
    setState(() => _status = 'Flushed');
  }

  Future<void> _openLogDir() async {
    final dir = await Log.getLogDir();
    setState(() => _status = 'logDir: ${dir.path}');

    Log.i('DEMO', 'logDir: ${dir.path}');
    if (Platform.isMacOS) {
      Log.i('DEMO', 'Tip: open "${dir.path}" in Finder to view log files.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_ytlog example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _logAllLevels,
              child: const Text('Log Levels'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _logBurst,
              child: const Text('Log Burst (short/long)'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _flush,
              child: const Text('Flush'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _openLogDir,
              child: const Text('Show Log Dir'),
            ),
          ],
        ),
      ),
    );
  }
}
