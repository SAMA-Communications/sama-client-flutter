import 'package:flutter/material.dart';

class AvatarLetterIcon extends StatelessWidget {
  const AvatarLetterIcon({required this.name, this.lastName, super.key});

  /// The text that will be used for the icon. It is truncated to 2 characters.
  final String name;
  final String? lastName;

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
          color: Colors.black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(4.0),
        height: 60.0,
        width: 55.0,
        child: Center(
          child: Text(
            getText(),
            style: const TextStyle(
                fontWeight: FontWeight.w400, color: Colors.grey, fontSize: 22),
          ),
        ));
  }
}
