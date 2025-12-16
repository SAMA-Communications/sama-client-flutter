import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../shared/ui/colors.dart';

import '../../../shared/ui/view/text_button_forms.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/utils/screen_factor.dart';
import '../bloc/reset_password_bloc.dart';
import '../bloc/timer_bloc/timer_bloc.dart';

class SendOtpForm extends StatelessWidget {
  const SendOtpForm({super.key});

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
    }, child: BlocBuilder<TimerBloc, TimerState>(builder: (context, state) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Reset password'),
          const Padding(padding: EdgeInsets.all(8)),
          Text(
              'We have sent a verification code to ${context.read<ResetPasswordBloc>().state.email.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              )),
          const Padding(padding: EdgeInsets.all(8)),
          const OtpInput(),
          const Padding(padding: EdgeInsets.all(8)),
          const Spacer(),
          _ContinueButton(),
          const Padding(padding: EdgeInsets.all(8)),
          const Text('Didn\'t receive the email?'),
          const Padding(padding: EdgeInsets.all(8)),
          RichText(
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
            text: TextSpan(
              text: 'Click to resend',
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (state.duration == 0) {
                    context
                        .read<ResetPasswordBloc>()
                        .add(const EmailSubmitted());
                  }
                },
              style: TextStyle(
                  color: state.duration == 0 ? slateBlue : dullGray,
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                if (state.duration != 0)
                  TextSpan(
                      text: ' in ${formatSecondsToTime(state.duration)}',
                      style: DefaultTextStyle.of(context).style),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(16))
        ],
      );
    }));
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
                onPressed: state.isOTPValid
                    ? () {
                        hideKeyboard();
                        context
                            .read<ResetPasswordBloc>()
                            .add(const OtpSubmitted());
                      }
                    : null,
                backgroundColor: WidgetStatePropertyAll(
                    state.isOTPValid ? slateBlue : whiteAluminum),
                foregroundColor: WidgetStatePropertyAll(
                    state.isOTPValid ? white : gainsborough),
                hint: 'Continue');
      },
    );
  }
}

class OtpInput extends StatefulWidget {
  static const otpSize = 6;

  const OtpInput({super.key});

  @override
  OtpInputState createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(OtpInput.otpSize, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(OtpInput.otpSize, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Enter the 6 digit OTP sent to your email",
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(OtpInput.otpSize, (index) {
              return digitField(index);
            }),
          ),
        ),
      ],
    );
  }

  Widget digitField(int index) {
    return Material(
      elevation: 8.0,
      borderRadius: BorderRadius.circular(5.0),
      shadowColor: black.withValues(alpha: 0.6),
      child: SizedBox(
        width: 45,
        height: 45,
        child: TextField(
          style: const TextStyle(fontSize: 22),
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          onChanged: (value) {
            if (value.characters.length == OtpInput.otpSize) {
              for (final (index, controller) in _controllers.indexed) {
                controller.text = value.characters.elementAt(index);
                if (index < 5) {
                  FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                }
                context
                    .read<ResetPasswordBloc>()
                    .add(OtpChanged(index, value.characters.elementAt(index)));
              }
              return;
            }

            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
            context.read<ResetPasswordBloc>().add(OtpChanged(index, value));
          },
          decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.only(
                bottom: 10,
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
