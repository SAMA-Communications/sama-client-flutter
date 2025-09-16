import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../shared/ui/colors.dart';

import '../../../shared/utils/screen_factor.dart';
import '../bloc/reset_password_bloc.dart';

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
    }, child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            builder: (context, state) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Reset password'),
          const Padding(padding: EdgeInsets.all(8)),
          Text('We have sent a verification code to ${state.email.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              )),
          const Padding(padding: EdgeInsets.all(8)),
          const OtpInput(),
          const Padding(padding: EdgeInsets.all(8)),
          _ContinueButton(),
          const Padding(padding: EdgeInsets.all(8)),
          RichText(
            text: TextSpan(
              text: 'Didn\'t receive the email?',
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                    text: ' Click to resend',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context
                            .read<ResetPasswordBloc>()
                            .add(const EmailSubmitted());
                      },
                    style: const TextStyle(
                        color: slateBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
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
                        state.isOTPValid ? slateBlue : whiteAluminum),
                    foregroundColor: WidgetStatePropertyAll(
                        state.isOTPValid ? white : gainsborough),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  onPressed: state.isOTPValid
                      ? () {
                          hideKeyboard();
                          context
                              .read<ResetPasswordBloc>()
                              .add(const OtpSubmitted());
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              );
      },
    );
  }
}

class OtpInput extends StatefulWidget {
  const OtpInput({super.key});

  @override
  OtpInputState createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
            children: List.generate(6, (index) {
              return digitField(index);
            }),
          ),
        ),
      ],
    );
  }

  Widget digitField(int index) {
    return SizedBox(
      width: 45,
      height: 45,
      child: TextField(
        style: const TextStyle(fontSize: 22),
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
          context.read<ResetPasswordBloc>().add(OtpChanged(index, value));
        },
        decoration: const InputDecoration(
            counterText: '',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.only(
              bottom: 10,
            )),
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
