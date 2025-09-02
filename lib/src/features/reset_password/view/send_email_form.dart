import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../models/models.dart';
import '../../../shared/ui/colors.dart';

import '../../../shared/utils/screen_factor.dart';
import '../bloc/reset_password_bloc.dart';

class SendEmailForm extends StatelessWidget {
  const SendEmailForm({super.key});

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
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Reset password'),
          const Padding(padding: EdgeInsets.all(8)),
          const Text(
              'To reset your password, enter the email that you used to create your account',
              style: TextStyle(
                fontSize: 12,
              )),
          const Padding(padding: EdgeInsets.all(8)),
          _EmailInput(),
          const Padding(padding: EdgeInsets.all(8)),
          _ContinueButton()
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      buildWhen: (previous, current) => previous.email != current.email,
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
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) =>
                context.read<ResetPasswordBloc>().add(EmailChanged(email)),
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                border: InputBorder.none,
                label: const Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: dullGray,
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    Text(
                      'Email',
                      style: TextStyle(color: dullGray, fontSize: 16),
                    )
                  ],
                ),
                errorText: state.email.displayError != null
                    ? state.email.displayError == EmailValidationError.empty
                        ? 'Email is too short'
                        : state.email.displayError ==
                                EmailValidationError.incorrect
                            ? 'The format of the email address is incorrect'
                            : null
                    : null),
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
                        state.isEmailValid ? slateBlue : whiteAluminum),
                    foregroundColor: WidgetStatePropertyAll(
                        state.isEmailValid ? white : gainsborough),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  onPressed: state.isEmailValid
                      ? () {
                          hideKeyboard();
                          context
                              .read<ResetPasswordBloc>()
                              .add(const EmailSubmitted());
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              );
      },
    );
  }
}
