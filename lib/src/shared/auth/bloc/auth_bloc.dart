import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../api/api.dart' as api;
import '../../../api/utils/logger.dart';
import '../../../repository/authentication/authentication_repository.dart';
import '../../../repository/user/user_repository.dart';
import '../../secure_storage.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(const AuthenticationState.unknown()) {
    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    on<AuthenticationSignOutRequested>(_onAuthenticationSignOutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(_AuthenticationStatusChanged(status)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
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
              ? AuthenticationState.authenticated(user)
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

  Future<api.User?> tryGetUser() async {
    try {
      return await _userRepository.getLocalUser();
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
        _authenticationRepository.disposeLocalUser();
      }
    }
  }

  Future<bool> tryGetHasLocalUser() async {
    try {
      return await SecureStorage.instance.hasLocalUser();
    } catch (_) {
      return false;
    }
  }
}
