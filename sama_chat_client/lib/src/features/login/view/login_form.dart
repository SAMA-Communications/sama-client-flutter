import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/ui/view/text_button_forms.dart';
import '../bloc/login_bloc.dart';
import '../models/models.dart';

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
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Align(
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
                      padding: const EdgeInsets.only(
                          left: 6.0, right: 6.0, bottom: 4),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            height: 1.0,
                            color: isSignupSelected ? gainsborough : black,
                            fontSize: 48),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 6.0, right: 6.0, bottom: 4),
                      child: Text(
                        'SignUp',
                        style: TextStyle(
                            height: 1.0,
                            color: isSignupSelected ? black : gainsborough,
                            fontSize: 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(8)),
            _UsernameInput(),
            const Padding(padding: EdgeInsets.all(8)),
            _PasswordInput(),
            if (isSignupSelected) ...[
              const Padding(padding: EdgeInsets.all(8)),
              _EmailInput(),
              const Padding(padding: EdgeInsets.all(4)),
            ] else ...[
              const Padding(padding: EdgeInsets.all(4)),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text("Forgot password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: slateBlue)),
                    onPressed: () => context.push(resetPasswordPath),
                  )),
            ],
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
        return TextFieldForm(
            onChanged: (username) =>
                context.read<LoginBloc>().add(LoginUsernameChanged(username)),
            iconData: Icons.person_outlined,
            text: 'Username',
            error: state.username.displayError != null
                ? state.username.displayError == UsernameValidationError.short
                    ? 'User name is too short'
                    : null
                : null);
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
        return TextFieldForm(
            keyboardType: TextInputType.visiblePassword,
            onChanged: (password) =>
                context.read<LoginBloc>().add(LoginPasswordChanged(password)),
            iconData: Icons.lock_outline,
            obscureText: isPasswordInvisible,
            suffix: IconButton(
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
                size: 22,
              ),
            ),
            text: 'Password',
            error: state.password.displayError != null
                ? state.password.displayError == PasswordValidationError.short
                    ? 'Password is too short'
                    : state.password.displayError ==
                            PasswordValidationError.long
                        ? 'Password is too long'
                        : state.password.displayError ==
                                PasswordValidationError.unavailableSymbols
                            ? 'Password contains not allowed symbols'
                            : null
                : null);
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFieldForm(
            onChanged: (email) =>
                context.read<LoginBloc>().add(LoginEmailChanged(email)),
            iconData: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            text: 'Email',
            error: state.email.displayError != null
                ? state.email.displayError == EmailValidationError.empty
                    ? 'Email is too short'
                    : state.email.displayError == EmailValidationError.incorrect
                        ? 'The format of the email is incorrect'
                        : null
                : null);
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isSignup;
  final bool isSighupWithLogin;

  const _LoginButton({required this.isSignup, required this.isSighupWithLogin});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        var isSignInValid = state.isValidLogin && !isSignup;
        var isSignUpValid = state.isValidSignup && isSignup;
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ButtonForm(
                onPressed: isSignInValid || isSignUpValid
                    ? () {
                        context.read<LoginBloc>().add(
                              LoginSubmitted(isSignup, isSighupWithLogin),
                            );
                      }
                    : null,
                backgroundColor: WidgetStatePropertyAll(
                    isSignInValid || isSignUpValid ? slateBlue : whiteAluminum),
                foregroundColor: WidgetStatePropertyAll(
                    isSignInValid || isSignUpValid ? white : gainsborough),
                text: isSignup ? 'Create account' : 'Login');
      },
    );
  }
}
