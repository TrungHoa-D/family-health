import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrefixPrinter(
    PrettyPrinter(methodCount: 3, colors: false, lineLength: 150),
  ),
);

var loggerNoStack = Logger(
  printer: PrefixPrinter(
    PrettyPrinter(methodCount: 0, colors: false, lineLength: 150),
  ),
);

class PrefixPrinter extends LogPrinter {
  PrefixPrinter(
    this._realPrinter, {
    debug,
    info,
    warning,
    error,
  }) : super() {
    _prefixMap = {
      Level.debug: debug ?? 'DEBUG ',
      Level.info: info ?? 'INFO ',
      Level.warning: warning ?? 'WARNING ',
      Level.error: error ?? 'ERROR ',
    };
  }

  final LogPrinter _realPrinter;
  late Map<Level, String> _prefixMap;

  @override
  List<String> log(LogEvent event) {
    return _realPrinter
        .log(event)
        .map((s) => '${_prefixMap[event.level]}$s')
        .toList();
  }
}
