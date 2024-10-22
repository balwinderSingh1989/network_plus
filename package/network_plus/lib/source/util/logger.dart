part of network_plus;

/// this will be the helper for logs. By default only logs are enabled only in debug builds,
/// to enable logs on release build as well change filter to ProductionFilter.
/// usage :
/// Log.d('This is a log');
class Log {
  static Logger? _logger;

  static void init(LoggerConfig config) {
    _logger = Logger(
      filter: config.shouldShowLogs ? DevelopmentFilter() : ProductionFilter(),
      level: _getLogLevel(config.logLevel),
      printer: PrettyPrinter(
        methodCount: config.methodCount,
        errorMethodCount: config.errorMethodCount,
        lineLength: config.lineLength,
        colors: config.colors,
        printEmojis: config.printEmojis,
        printTime: config.printTime,
      ),
      output: null,
    );
  }

  static Level _getLogLevel(LogsLevel logLevel) {
    switch (logLevel) {
      case LogsLevel.debug:
        return Level.debug;
      case LogsLevel.fatal:
        return Level.fatal;
      case LogsLevel.info:
        return Level.info;
      case LogsLevel.warning:
        return Level.warning;
      case LogsLevel.error:
        return Level.error;
      case LogsLevel.trace:
        return Level.trace;
      case LogsLevel.off:
        return Level.off;
      default:
        return Level.all;
    }
  }

  static void d(String message) {
    _logger?.d(message);
  }

  static void e(String message) {
    _logger?.e(message);
  }

  static void i(String message) {
    _logger?.i(message);
  }

  static void t(String message) {
    _logger?.t(message);
  }

  static void f(String message) {
    _logger?.f(message);
  }

  static void w(String message) {
    _logger?.w(message);
  }
}

