import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../shared/ui/view/text_button_forms.dart';
import '../models/models.dart';
import '../../../shared/ui/colors.dart';

import '../../../shared/utils/screen_factor.dart';
import '../bloc/reset_password_bloc.dart';

class SendResetPasswordForm extends StatelessWidget {
  const SendResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
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
              SnackBar(
                  content: Text(state.informationMessage ?? '',
                      textAlign: TextAlign.center)),
            );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Set new password', style: TextStyle(fontSize: 20)),
          const Padding(padding: EdgeInsets.all(8)),
          _PasswordInput(),
          const Padding(padding: EdgeInsets.all(8)),
          _ConfirmPasswordInput(),
          const Padding(padding: EdgeInsets.all(8)),
          const Spacer(),
          _ContinueButton(),
          const Padding(padding: EdgeInsets.all(16))
        ],
      ),
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
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFieldForm(
            keyboardType: TextInputType.visiblePassword,
            onChanged: (psw) =>
                context.read<ResetPasswordBloc>().add(PasswordChanged(psw)),
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
                size: 22,
                color: dullGray,
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

class _ConfirmPasswordInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConfirmPasswordInputState();
  }
}

class _ConfirmPasswordInputState extends State<_ConfirmPasswordInput> {
  bool isPasswordInvisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      buildWhen: (previous, current) =>
          previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        return TextFieldForm(
          keyboardType: TextInputType.visiblePassword,
          onChanged: (psw) => context
              .read<ResetPasswordBloc>()
              .add(ConfirmPasswordChanged(psw)),
          iconData: Icons.lock_outline,
          text: 'Confirm password',
          error: state.confirmPassword.displayError != null
              ? state.confirmPassword.displayError ==
                      ConfirmPasswordValidationError.empty
                  ? 'Password is too short'
                  : state.confirmPassword.displayError ==
                          ConfirmPasswordValidationError.notMatching
                      ? 'Passwords do NOT match'
                      : null
              : null,
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
              size: 22,
              color: dullGray,
            ),
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ButtonForm(
                onPressed: state.isPasswordValid
                    ? () {
                        hideKeyboard();
                        context
                            .read<ResetPasswordBloc>()
                            .add(const PasswordSubmitted());
                      }
                    : null,
                backgroundColor: WidgetStatePropertyAll(
                    state.isPasswordValid ? slateBlue : whiteAluminum),
                foregroundColor: WidgetStatePropertyAll(
                    state.isPasswordValid ? white : gainsborough),
                text: 'Continue');
      },
    );
  }
}
