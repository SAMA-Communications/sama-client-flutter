import 'dart:convert';

const String samaLogTag = 'SAMA';

class SamaLogger {
  SamaLogger._();

  static final _instance = SamaLogger._();

  static SamaLogger get instance {
    return _instance;
  }

  bool printLogs = true;
}

log(String subTag, {Map<dynamic, dynamic>? jsonData, String? stringData}) {
  if (SamaLogger.instance.printLogs) {
    print(
        '$samaLogTag: $subTag: ${jsonData != null ? '\n${const JsonEncoder.withIndent('  ').convert(jsonData)}' : stringData}');
  }
}
