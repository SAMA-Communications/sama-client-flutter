import 'dart:async';

import '../../api.dart';

class UsersManager {
  UsersManager._() {
    _init();
  }

  static final _instance = UsersManager._();

  static UsersManager get instance {
    return _instance;
  }

  StreamSubscription<Map<String, dynamic>>? _dataListener;

  final StreamController<Map<String, int>> _lastActivityController =
      StreamController.broadcast();

  Stream<Map<String, int>> get lastActivityControllerStream =>
      _lastActivityController.stream;

  _init() {
    if (_dataListener != null) return;

    _dataListener = SamaConnectionService.instance.dataStream.listen((data) {
      if (data['last_activity'] != null) {
        _processLastActivity(data['last_activity'].cast<String, int>());
      }
    });
  }

  void _processLastActivity(Map<String, int> data) {
    _lastActivityController.add(data);
  }

  destroy() {
    _dataListener?.cancel();
    _dataListener = null;
  }
}
