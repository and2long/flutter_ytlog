A logging utility class that supports color-coded logs in the terminal and enables writing logs to a file for persistent storage.

## Usage

```dart
import 'package:flutter_ytlog/flutter_ytlog.dart';

Log.d('TAG', 'Hello World');
Log.i('TAG', 'Hello World');
Log.w('TAG', 'Hello World');
Log.e('TAG', 'Hello World');
```

## Initialize configuration (optional)
```
Log.init(enable: true, writeToFile: true);
```

## Get log folder
```
Directory logDir = await Log.getLogDir();
```

## Get current log file
```
File logFile = await Log.getLogFile();
```