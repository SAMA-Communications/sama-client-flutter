import 'package:formz/formz.dart';

enum OtpValidationError { empty, wrongLength, unavailableSymbols }

const int otpLength = 4;

class Otp extends FormzInput<String, OtpValidationError> {
  const Otp.pure() : super.pure('xxxx');

  const Otp.dirty([super.value = '']) : super.dirty();

  @override
  OtpValidationError? validator(String value) {
    if (value.isEmpty) return OtpValidationError.empty;

    if (value.length != otpLength) return OtpValidationError.wrongLength;
    if (int.tryParse(value) == null) {
      return OtpValidationError.unavailableSymbols;
    }
    return null;
  }
}
