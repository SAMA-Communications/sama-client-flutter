import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../shared/ui/view/text_button_forms.dart';
import '../../../shared/utils/date_utils.dart';
import '../bloc/timer_bloc/timer_bloc.dart';
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
          const Spacer(),
          _ContinueButton(),
          const Padding(padding: EdgeInsets.all(16))
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
        return TextFieldForm(
            onChanged: (email) =>
                context.read<ResetPasswordBloc>().add(EmailChanged(email)),
            iconData: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            hint: 'Email',
            error: state.email.displayError != null
                ? state.email.displayError == EmailValidationError.empty
                    ? 'Email is too short'
                    : state.email.displayError == EmailValidationError.incorrect
                        ? 'The format of the email address is incorrect'
                        : null
                : null);
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final ValueNotifier<String> snackBarText = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(listener: (context, state) {
      snackBarText.value =
          'Can continue in ${formatSecondsToTime(state.duration)}';
    }, child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ButtonForm(
                onPressed: state.isEmailValid
                    ? () {
                        hideKeyboard();
                        var time = context.read<TimerBloc>().state.duration;
                        if (time != 0) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: ValueListenableBuilder<String>(
                                  valueListenable: snackBarText,
                                  builder: (context, currentText, child) {
                                    return Text(currentText,
                                        textAlign: TextAlign.center);
                                  },
                                ),
                              ),
                            );
                        } else {
                          context
                              .read<ResetPasswordBloc>()
                              .add(const EmailSubmitted());
                        }
                      }
                    : null,
                backgroundColor: WidgetStatePropertyAll(
                    state.isEmailValid ? slateBlue : whiteAluminum),
                foregroundColor: WidgetStatePropertyAll(
                    state.isEmailValid ? white : gainsborough),
                hint: 'Continue');
      },
    ));
  }
}
