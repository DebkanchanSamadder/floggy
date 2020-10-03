import 'package:logger/logger.dart';

/// Different logger types
/// This is how user can make custom logger type that can easily later get put to
/// blacklist or whitelist and it will show it's tag along with class that called it
/// if used added [runtimeType] to Logger's name.
mixin BlacklistedLogger implements LoggerType {
  @override
  Logger<BlacklistedLogger> get log => Logger<BlacklistedLogger>('Blacklisted Logger - ${runtimeType.toString()}');
}

/// Custom logger type can have any name
mixin ExampleLogger implements LoggerType {
  @override
  Logger<ExampleLogger> get log => Logger<ExampleLogger>('Example');
}

/// We can also add new [Level] to the Logger that is not in the lib.
/// Here we add new [WtfLevel] with priority of 32 (2^5), meaning it's has more
/// priority than error (16 (2^4)).
extension WtfLevel on Level {
  static const Level wtf = Level('WTF', 32);
}

/// We can also add short version of log for our newly created [Level]
extension WtfLogger on Logger {
  void wtf(dynamic message, [Object error, StackTrace stackTrace]) => log(WtfLevel.wtf, message, error, stackTrace);
}

/// We can also extend our [PrettyPrinter] and add our colors and prefix to
/// new level, or even change the existing ones.
class PrettyWtfPrinter extends PrettyPrinter {
  const PrettyWtfPrinter() : super();

  @override
  AnsiColor levelColor(Level level) {
    if (level == WtfLevel.wtf) {
      return AnsiColor(foregroundColor: 141);
    }
    return super.levelColor(level);
  }

  @override
  String levelPrefix(Level level) {
    if (level == WtfLevel.wtf) {
      return '👾 ';
    }
    return super.levelPrefix(level);
  }
}

void main() {
  Logger.initLogger(
    logPrinter: const PrettyWtfPrinter(),
    logLevel: const LogOptions(
      Level.all,
      // includeCallerInfo: true,
    ),
    blacklist: [BlacklistedLogger],
  );

  ExampleNetworkLogger();
  ExampleUiLogger();
  ExampleBlackListedLogger();
  ExampleWhatLoggersCanDo();
}

class ExampleNetworkLogger with NetworkLogger {
  ExampleNetworkLogger() {
    log.debug('This is log from Network logger');
    log.info('This is log from Network logger');
    log.warning('This is log from Network logger');
    log.error('This is log from Network logger');

    log.wtf('This is log with custom log level in Network logger');
  }
}

class ExampleUiLogger with UiLogger {
  ExampleUiLogger() {
    log.warning('This is log from UI logger');
    log.warning('This is log from UI logger');
    log.warning('This is log from UI logger');
    log.warning('This is log from UI logger');

    log.wtf('This is log with custom log level in UI logger');
  }
}

class ExampleBlackListedLogger with BlacklistedLogger {
  ExampleBlackListedLogger() {
    log.info('This log is from Blacklisted logger and should not be visible!');
    log.warning('This log is from Blacklisted logger and should not be visible!');
  }
}

class ExampleWhatLoggersCanDo with ExampleLogger {
  ExampleWhatLoggersCanDo() {
    /// This will evaluate only if line is actually logged
    log.info('Loggers can do some stuff:');
    log.info('You can pass function to the logger, it will evaluate only if log gets shown');
    log.debug(() {
      /// You can log in log
      log.warning('Using logger inside of the logger #WeNeedToGoDeeper');

      /// Do something here maybe?
      return [1, 2, 3, 4, 5].map((e) => e * 4).join('-');
    });

    void _insideLogger() {
      final _logger = logger('Test');

      /// This only works if [Logger.hierarchicalLoggingEnabled] is set to true
      // _logger.level = LogLevel(Level.all);
      _logger.debug('I\'m new logger called "${_logger.name}" and my parent logger name is "${_logger.parent.name}"');
      _logger.debug('Even if I\'m a new logger, I still share everything with my parent');
    }

    void _detachedLogger() {
      final _logger = detachedLogger('Detached logger');
      _logger.level = const LogOptions(Level.all);
      _logger.onRecord.listen((event) {
        print(event);
      });
      _logger.debug(
          'I\'m a detached logger. I don\'t have a parent and I have no connection or shared info with root logger!');
    }

    _insideLogger();
    _detachedLogger();
  }
}
