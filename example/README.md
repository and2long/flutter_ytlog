## flutter_ytlog example

Run:

```bash
cd example
flutter create . --platforms=ios,android
flutter pub get
flutter run
```

Notes:
- Use the buttons to generate logs of different levels and verify color output in a terminal that supports ANSI.
- If `writeToFile` is enabled, tap "Flush" to wait until all queued logs are written before checking the log file.

