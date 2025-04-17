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

  final StreamController<Map<String, dynamic>> _lastActivityController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get lastActivityControllerStream =>
      _lastActivityController.stream;

  _init() {
    if (_dataListener != null) return;

    _dataListener = SamaConnectionService.instance.dataStream.listen((data) {
      if (data['last_activity'] != null) {
        _processLastActivity(data['last_activity'].cast<String, dynamic>());
      }
    });
  }

  void _processLastActivity(Map<String, dynamic> data) {
    _lastActivityController.add(data);
  }

  destroy() {
    _dataListener?.cancel();
    _dataListener = null;
  }
}
