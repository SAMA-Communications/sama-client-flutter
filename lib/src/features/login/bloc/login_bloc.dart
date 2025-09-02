import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../repository/authentication/authentication_repository.dart';
import '../../../shared/models/email.dart';
import '../models/models.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = Username.dirty(event.username);
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        username: username,
        isValidLogin: Formz.validate([state.password, username]),
        isValidSignup: Formz.validate([state.password, state.email, username]),
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        password: password,
        isValidLogin: Formz.validate([password, state.username]),
        isValidSignup: Formz.validate([password, state.email, state.username]),
      ),
    );
  }

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    final email = Email.dirty(event.email);

    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        email: email,
        isValidSignup: Formz.validate([state.password, email, state.username]),
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isValidLogin && !event.isSignup ||
        state.isValidSignup && event.isSignup) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        Future<void> requiredMethod;
        if (event.isSignup) {
          requiredMethod = _authenticationRepository.signUp(
              username: state.username.value.trim(),
              password: state.password.value.trim(),
              email: state.email.value.trim(),
              signInWithCreatedUser: event.isSighupWithLogin);
        } else {
          requiredMethod = _authenticationRepository.login(
            username: state.username.value.trim(),
            password: state.password.value.trim(),
          );
        }

        await requiredMethod.then((_) {
          emit(state.copyWith(
              status: FormzSubmissionStatus.success,
              informationMessage:
                  event.isSignup ? 'New user was successfully created' : null));
        }).catchError((onError) {
          emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: onError.toString()));
        });
      } catch (_) {}
    }
  }
}
