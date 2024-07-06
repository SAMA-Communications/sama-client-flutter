import 'dart:async';

import 'package:app_set_id/app_set_id.dart';

import '../../api/api.dart' as api;

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    var deviceId = await AppSetId().getIdentifier();

    try {
      await api.login(
          api.User(login: username, password: password, deviceId: deviceId));
      api.ReconnectionManager.instance.init();
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
        await api.login(
            api.User(login: username, password: password, deviceId: deviceId));
        api.ReconnectionManager.instance.init();
        _controller.add(AuthenticationStatus.authenticated);
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
    await api.logout().then((success) {
      api.ReconnectionManager.instance.destroy();
      _controller.add(AuthenticationStatus.unauthenticated);
    });
  }

  void dispose() => _controller.close();
}
