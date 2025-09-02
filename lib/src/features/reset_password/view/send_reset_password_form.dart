import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
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
              SnackBar(content: Text(state.informationMessage ?? '')),
            );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set new password'),
            const Padding(padding: EdgeInsets.all(8)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(8)),
            _ConfirmPasswordInput(),
            const Padding(padding: EdgeInsets.all(8)),
            _ContinueButton()
          ],
        ),
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
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            color: gainsborough,
          ),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            onChanged: (psw) =>
                context.read<ResetPasswordBloc>().add(PasswordChanged(psw)),
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
                              PasswordValidationError.long
                          ? 'Password is too long'
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
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            color: gainsborough,
          ),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            onChanged: (psw) => context
                .read<ResetPasswordBloc>()
                .add(ConfirmPasswordChanged(psw)),
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
                    'Confirm password',
                    style: TextStyle(color: dullGray, fontSize: 16),
                  )
                ],
              ),
              errorText: state.confirmPassword.displayError != null
                  ? state.confirmPassword.displayError ==
                          ConfirmPasswordValidationError.empty
                      ? 'Password is too short'
                      : state.confirmPassword.displayError ==
                              ConfirmPasswordValidationError.notMatching
                          ? 'Passwords do NOT match'
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

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
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
                        state.isPasswordValid ? slateBlue : whiteAluminum),
                    foregroundColor: WidgetStatePropertyAll(
                        state.isPasswordValid ? white : gainsborough),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  onPressed: state.isPasswordValid
                      ? () {
                          hideKeyboard();
                          context
                              .read<ResetPasswordBloc>()
                              .add(const PasswordSubmitted());
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              );
      },
    );
  }
}
