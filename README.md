<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

A logging utility class that supports color-coded logs in the terminal and enables writing logs to a file for persistent storage.

## Usage

```dart
import 'package:flutter_ytlog/log.dart';

Log.d('TAG', 'Hello World');
Log.i('TAG', 'Hello World');
Log.w('TAG', 'Hello World');
Log.e('TAG', 'Hello World');
```
