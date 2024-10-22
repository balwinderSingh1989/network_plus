import 'package:flutter/foundation.dart';

/// LoggerConfig class and Log utility
///
/// This setup allows you to configure the logger comprehensively through the `LoggerConfig` class,
/// including setting the log level. This approach keeps your configuration centralized and easy to manage.
///
/// ### Usage:
///
/// 1. Define the configuration for your logger using `LoggerConfig`:
///
/// ```dart
/// final loggerConfig = LoggerConfig(
///   debugOnly: true, // Log only in debug mode
///   methodCount: 3, // Number of method calls to be displayed
///   errorMethodCount: 5, // Number of method calls if stacktrace is provided
///   lineLength: 100, // Width of the output
///   colors: true, // Colorful log messages
///   printEmojis: true, // Print an emoji for each log message
///   printTime: true, // Should each log print contain a timestamp
///   logLevel: LogLevel.warning, // Set the logging level
/// );
/// ```
///
/// 2. Initialize the logger with the configuration:
///
/// ```dart
/// Log.init(loggerConfig);
/// ```
///
/// 3. Use the `Log` class to log messages:
///
/// ```dart
/// Log.d("This is a debug message");
/// Log.e("This is an error message");
/// Log.i("This is an info message");
/// Log.t("This is a trace message");
/// Log.f("This is a fatal message");
/// ```

enum LogsLevel {
  warning,
  error,
  all,
  debug,
  fatal,
  info,
  off,
  trace,
}

class LoggerConfig {
  final bool shouldShowLogs;
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;
  final LogsLevel logLevel;

  const LoggerConfig({
    this.shouldShowLogs = kDebugMode,
    this.methodCount = 2,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
    this.logLevel = LogsLevel.all
  });
}
