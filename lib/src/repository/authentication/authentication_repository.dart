import 'dart:async';
import 'package:app_set_id/app_set_id.dart';

import '../../api/api.dart' as api;
import '../../api/api.dart';
import '../../db/db_service.dart';
import '../../shared/secure_storage.dart';
import '../user/user_repository.dart';

enum AuthenticationStatus {
  unknown,
  canBeAuthenticated,
  authenticated,
  unauthenticated
}

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>.broadcast();
  final UserRepository userRepository;

  AuthenticationRepository(this.userRepository);

  Stream<AuthenticationStatus> get status async* {
    //TODO RP not clear why this delay is needed, commented for now
    // await Future<void>.delayed(const Duration(seconds: 1));
    if (await SecureStorage.instance.hasCurrentUser()) {
      yield AuthenticationStatus.canBeAuthenticated;
    }
    yield* _controller.stream;
  }

  Future<void> login({
    required String username,
    String? password,
    String? deviceId,
  }) async {
    try {
      User user = api.User(
          login: username,
          password: password,
          deviceId: deviceId ?? await AppSetId().getIdentifier());
      var (accessToken, loggedUser) = await api.loginHttp(user);
      await loginWithAccessToken(accessToken);
      await userRepository.updateUserLocal(loggedUser);
      return Future.value(null);
    } catch (e) {
      _controller.add(AuthenticationStatus.unauthenticated);
      return Future.error(
          e is ResponseException ? (e).message ?? e.toString() : e.toString());
    }
  }

  Future<void> loginWithAccessToken([AccessToken? accessToken]) async {
    ReconnectionManager.instance.init();
    DatabaseService.instance.init();
    try {
      await api.loginWithToken(accessToken);

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
        login(username: username, password: password, deviceId: deviceId);
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
    await api.logout().whenComplete(() {
      disposeCurrentUser();
    });
  }

  Future<void> signOut() async {
    await api.PushNotificationsManager.instance.unsubscribe();
    await api.signOut().then((success) {
      disposeCurrentUser();
    });
  }

  disposeCurrentUser() async {
    await SecureStorage.instance.deleteCurrentUser();
    api.ReconnectionManager.instance.destroy();
    api.SamaConnectionService.instance.closeConnection();
    DatabaseService.instance.drop();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
