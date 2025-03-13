import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../api/api.dart' as api;
import '../../../api/utils/logger.dart';
import '../../../db/models/models.dart';
import '../../../repository/authentication/authentication_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../secure_storage.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState.unknown()) {
    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    on<AuthenticationSignOutRequested>(_onAuthenticationSignOutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(_AuthenticationStatusChanged(status)),
    );
    _connectionStateSubscription = api
        .SamaConnectionService.instance.connectionStateStream
        .listen((status) async {
      if (status == api.ConnectionState.connected &&
          state.status == AuthenticationStatus.unauthenticated) {
        if (await SecureStorage.instance.hasCurrentUser()) {
          tryAuthUser();
        }
      }
    });
  }

  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;
  late StreamSubscription<api.ConnectionState> _connectionStateSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _connectionStateSubscription.cancel();
    return super.close();
  }

  Future<void> _onAuthenticationStatusChanged(
    _AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return emit(const AuthenticationState.unauthenticated());
      case AuthenticationStatus.authenticated:
        final user = await tryGetUser();
        return emit(
          user != null
              ? AuthenticationState.authenticated(user.id!)
              : const AuthenticationState.unauthenticated(),
        );
      case AuthenticationStatus.unknown:
        return emit(const AuthenticationState.unknown());
      case AuthenticationStatus.canBeAuthenticated:
        tryAuthUser();
    }
  }

  Future<void> _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await _authenticationRepository.logOut();
      emit(const AuthenticationState.unauthenticated());
    } catch (_) {}
  }

  Future<void> _onAuthenticationSignOutRequested(
    AuthenticationSignOutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await _authenticationRepository.signOut();
      emit(const AuthenticationState.unauthenticated());
    } catch (_) {}
  }

  Future<UserModel?> tryGetUser() async {
    try {
      return await SecureStorage.instance.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> tryAuthUser() async {
    try {
      await _authenticationRepository.loginWithAccessToken();
    } catch (e) {
      log('tryAuthUser e= $e');
      //TODO RP CHECK ME
      if (e.toString().contains('Expired')) {
        _authenticationRepository.disposeCurrentUser();
      }
    }
  }

  Future<bool> tryGetHasCurrentUser() async {
    try {
      return await SecureStorage.instance.hasCurrentUser();
    } catch (_) {
      return false;
    }
  }
}
