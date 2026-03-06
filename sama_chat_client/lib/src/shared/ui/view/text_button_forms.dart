import 'package:flutter/material.dart';

import '../colors.dart';

class TextFieldForm extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final IconData iconData;
  final String text;
  final TextInputType? keyboardType;
  final String? error;
  final Widget? suffix;
  final bool? obscureText;

  const TextFieldForm(
      {super.key,
      required this.onChanged,
      required this.iconData,
      required this.text,
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
          onChanged: (username) => onChanged(username),
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
                Expanded(
                    child: Text(
                  error ?? text,
                  style: TextStyle(
                      color: error != null ? red : dullGray, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffix ?? const SizedBox(),
            ),
          ),
        ));
  }
}

class ButtonForm extends StatelessWidget {
  final VoidCallback? onPressed;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final String text;
  final TextStyle? textStyle;

  const ButtonForm(
      {super.key,
      required this.onPressed,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.text,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      height: 46,
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
