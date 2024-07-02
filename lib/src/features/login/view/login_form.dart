import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../shared/ui/colors.dart';
import '../bloc/login_bloc.dart';
import '../models/password.dart';
import '../models/username.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  List<bool> loginSignupSelection = [true, false];
  bool isSignupSelected = false;
  bool loginWithNewUser = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '')),
            );
        } else if (state.status.isSuccess && state.informationMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.informationMessage ?? '')),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderColor: Colors.transparent,
                fillColor: Colors.transparent,
                selectedBorderColor: Colors.transparent,
                selectedColor: Colors.transparent,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < loginSignupSelection.length; i++) {
                      loginSignupSelection[i] = i == index;
                    }
                    isSignupSelected = loginSignupSelection[1];
                  });
                },
                isSelected: loginSignupSelection,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 6.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: isSignupSelected ? gainsborough : black,
                          fontSize: 54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 6.0),
                    child: Text(
                      'SignUp',
                      style: TextStyle(
                          color: isSignupSelected ? black : gainsborough,
                          fontSize: 54),
                    ),
                  ),
                ],
              ),
            ),
            _UsernameInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(4)),
            Visibility(
                visible: isSignupSelected,
                child: Row(
                  children: [
                    Checkbox(
                        checkColor: white,
                        activeColor: whiteAluminum,
                        value: loginWithNewUser,
                        onChanged: (checked) {
                          setState(() {
                            loginWithNewUser = checked ?? true;
                          });
                        }),
                    const Text('* Sign in automatically as a new user')
                  ],
                )),
            const Padding(padding: EdgeInsets.all(4)),
            _LoginButton(
              isSignup: isSignupSelected,
              isSighupWithLogin: loginWithNewUser,
            ),
            const Padding(padding: EdgeInsets.all(8)),
            RichText(
              text: TextSpan(
                text: isSignupSelected
                    ? 'Already have an account?'
                    : 'New to app? ',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: isSignupSelected ? ' Log in' : ' Create an account',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            isSignupSelected = !isSignupSelected;
                          });
                        },
                      style: const TextStyle(
                          color: slateBlue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(8)),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: gainsborough,
          ),
          child: TextField(
            key: const Key('loginForm_usernameInput_textField'),
            onChanged: (username) =>
                context.read<LoginBloc>().add(LoginUsernameChanged(username)),
            decoration: InputDecoration(
              border: InputBorder.none,
              label: const Row(
                children: [
                  Icon(
                    Icons.person_outlined,
                    size: 16,
                    color: dullGray,
                  ),
                  Text(
                    'Username',
                    style: TextStyle(color: dullGray, fontSize: 16),
                  )
                ],
              ),
              errorText: state.username.displayError != null
                  ? state.username.displayError == UsernameValidationError.short
                      ? 'User name is too short'
                      : null
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PasswordInputState();
  }
}

class _PasswordInputState extends State<_PasswordInput> {
  bool isPasswordInvisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            color: gainsborough,
          ),
          child: TextField(
            key: const Key('loginForm_passwordInput_textField'),
            onChanged: (password) =>
                context.read<LoginBloc>().add(LoginPasswordChanged(password)),
            obscureText: isPasswordInvisible,
            obscuringCharacter: '*',
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              label: const Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: dullGray,
                  ),
                  Text(
                    'Password',
                    style: TextStyle(color: dullGray, fontSize: 16),
                  )
                ],
              ),
              errorText: state.password.displayError != null
                  ? state.password.displayError == PasswordValidationError.short
                      ? 'Password is too short'
                      : state.password.displayError ==
                              PasswordValidationError.unavailableSymbols
                          ? 'Password contains not allowed symbols'
                          : null
                  : null,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordInvisible = !isPasswordInvisible;
                    });
                  },
                  icon: Icon(
                    isPasswordInvisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: dullGray,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isSignup;
  final bool isSighupWithLogin;

  const _LoginButton(
      {super.key, required this.isSignup, required this.isSighupWithLogin});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                height: 46,
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        state.isValid ? slateBlue : whiteAluminum),
                    foregroundColor: WidgetStatePropertyAll(
                        state.isValid ? white : gainsborough),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  key: const Key('loginForm_continue_raisedButton'),
                  onPressed: state.isValid
                      ? () {
                          context.read<LoginBloc>().add(
                                LoginSubmitted(isSignup, isSighupWithLogin),
                              );
                        }
                      : null,
                  child: Text(isSignup ? 'Create account' : 'Login'),
                ),
              );
      },
    );
  }
}
