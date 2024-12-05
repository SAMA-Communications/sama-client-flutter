import 'dart:async';
import 'package:app_set_id/app_set_id.dart';

import '../../api/api.dart' as api;
import '../../shared/secure_storage.dart';

enum AuthenticationStatus {
  unknown,
  canBeAuthenticated,
  authenticated,
  unauthenticated
}

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    //TODO RP not clear why this delay is needed, commented for now
    // await Future<void>.delayed(const Duration(seconds: 1));
    if (await SecureStorage.instance.hasLocalUser()) {
      yield AuthenticationStatus.canBeAuthenticated;
    } else {
      yield AuthenticationStatus.unauthenticated;
    }
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
    String? deviceId,
  }) async {
    try {
      api.User user = api.User(
          login: username,
          password: password,
          deviceId: deviceId ?? await AppSetId().getIdentifier());
      api.User result = (await api.login(user))
          .copyWith(password: password, deviceId: user.deviceId);
      SecureStorage.instance.saveLocalUserIfNeed(result);
      api.ReconnectionManager.instance.init();
      api.PushNotificationsManager.instance.subscribe();
      _controller.add(AuthenticationStatus.authenticated);
      return Future.value(null);
    } catch (e) {
      _controller.add(AuthenticationStatus.unauthenticated);
      return Future.error((e as api.ResponseException).message ?? '');
    }
  }

  Future<void> signUp({
    required String username,
    required String password,
    bool signInWithCreatedUser = true,
  }) async {
    var deviceId = await AppSetId().getIdentifier();

    try {
      await api.createUser(
          login: username, password: password, deviceId: deviceId ?? '');

      if (signInWithCreatedUser) {
        logIn(username: username, password: password, deviceId: deviceId);
      }

      return Future.value(null);
    } catch (e) {
      if (signInWithCreatedUser) {
        _controller.add(AuthenticationStatus.unauthenticated);
      }
      return Future.error((e as api.ResponseException).message ?? '');
    }
  }

  Future<void> logOut() async {
    await api.PushNotificationsManager.instance.unsubscribe();
    await api.logout().then((success) {
      _disposeLocalUser();
    });
  }

  Future<void> signOut() async {
    await api.PushNotificationsManager.instance.unsubscribe();
    await api.signOut().then((success) {
      _disposeLocalUser();
    });
  }

  _disposeLocalUser() async {
    await SecureStorage.instance.deleteLocalUser();
    api.ReconnectionManager.instance.destroy();
    api.SamaConnectionService.instance.closeConnection();
    api.ConnectionManager.instance.currentUser = null;
    api.ConnectionManager.instance.token = null;
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
