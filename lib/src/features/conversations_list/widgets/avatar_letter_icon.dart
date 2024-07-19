import 'package:flutter/material.dart';

class AvatarLetterIcon extends StatelessWidget {
  const AvatarLetterIcon({
    required this.name,
    this.lastName,
    super.key,
    this.size = const Size(55, 60),
    this.borderRadius = 5.0,
    this.backgroundColor = black,
    this.textColor = dullGray,
  });

  /// The text that will be used for the icon. It is truncated to 2 characters.
  final String name;
  final String? lastName;
  final Size size;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;

  String getText() {
    if (name.isNotEmpty && ((lastName ?? '') != '')) {
      return name.substring(0, 1).toUpperCase() +
          lastName!.substring(0, 1).toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(4.0),
      height: size.height,
      width: size.width,
      child: Center(
        child: Text(
          getText(),
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: textColor,
              fontSize: size.height / 2.7),
        ),
      ),
    );
  }
}
