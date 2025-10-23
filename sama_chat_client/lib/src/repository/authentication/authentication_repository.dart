import 'dart:async';
import 'package:app_set_id/app_set_id.dart';
import 'package:sama_chat_api/api/api.dart';
import 'package:sama_chat_api/api/api.dart' as api;

import '../../db/db_service.dart';
import '../../db/models/models.dart';
import '../../shared/push_notifications/push_notifications_manager.dart';
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

  AuthenticationRepository(this.userRepository) {
    initListeners();
  }

  Stream<AuthenticationStatus> get status async* {
    //TODO RP not clear why this delay is needed, commented for now
    // await Future<void>.delayed(const Duration(seconds: 1));
    if (await SecureStorage.instance.hasCurrentUser()) {
      yield AuthenticationStatus.canBeAuthenticated;
    }
    yield* _controller.stream;
  }

  StreamSubscription<ReconnectionState>? reconnectionStream;

  void initListeners() {
    if (reconnectionStream != null) return;

    reconnectionStream = ReconnectionManager.instance.reconnectionStateStream
        .listen((state) async {
      if (state == ReconnectionState.tokenExpired) {
        await logOut();
        _controller.add(AuthenticationStatus.unauthenticated);
      }
    });
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
      var loggedUserModel = loggedUser.toUserModel();
      SecureStorage.instance.saveCurrentUserIfNeed(loggedUserModel);
      await loginWithAccessToken(accessToken);
      await userRepository.updateUserLocal(loggedUserModel);
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

      PushNotificationsManager.instance.subscribe();
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
    required String email,
    bool signInWithCreatedUser = true,
  }) async {
    var deviceId = await AppSetId().getIdentifier();

    try {
      await api.createUser(
          login: username,
          password: password,
          email: email,
          deviceId: deviceId ?? '');

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
    await PushNotificationsManager.instance.unsubscribe();
    await api.logout().whenComplete(() {
      disposeCurrentUser();
    });
  }

  Future<void> signOut() async {
    await PushNotificationsManager.instance.unsubscribe();
    await api.signOut().then((success) {
      disposeCurrentUser();
    });
  }

  Future<void> sendOtpEmail(String email) async {
    try {
      await api.sendOtpEmail(email);
      return Future.value(null);
    } catch (e) {
      return Future.error((e as api.ResponseException).message ?? '');
    }
  }

  Future<void> sendResetPassword(
      String email, int token, String newPassword) async {
    try {
      await api.sendResetPassword(email, token, newPassword);
      return Future.value(null);
    } catch (e) {
      return Future.error((e as api.ResponseException).message ?? '');
    }
  }

  disposeCurrentUser() async {
    await SecureStorage.instance.deleteCurrentUser();
    ReconnectionManager.instance.destroy();
    api.SamaConnectionService.instance.closeConnection();
    DatabaseService.instance.drop();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() {
    reconnectionStream?.cancel();
    reconnectionStream = null;
    _controller.close();
  }
}
