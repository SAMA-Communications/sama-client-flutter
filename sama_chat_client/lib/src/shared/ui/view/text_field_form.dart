import 'package:flutter/material.dart';

import '../colors.dart';

class TextFieldForm extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final IconData iconData;
  final String hint;
  final TextInputType? keyboardType;
  final String? error;
  final Widget? suffix;
  final bool? obscureText;

  const TextFieldForm(
      {super.key,
      required this.onChanged,
      required this.iconData,
      required this.hint,
      this.keyboardType,
      this.error,
      this.suffix,
      this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        height: 55,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          color: gainsborough,
        ),
        child: TextField(
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 17),
          autocorrect: false,
          enableSuggestions: false,
          obscuringCharacter: '*',
          obscureText: obscureText ?? false,
          onChanged: (username) => onChanged,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 12.0),
            isDense: true,
            label: Row(
              spacing: 10,
              children: [
                Icon(
                  iconData,
                  size: 26,
                  color: dullGray,
                ),
                Text(
                  hint,
                  style: const TextStyle(color: dullGray, fontSize: 16),
                )
              ],
            ),
            errorText: error,
            suffixIcon: suffix ?? const SizedBox(),
          ),
        ));
  }
}
