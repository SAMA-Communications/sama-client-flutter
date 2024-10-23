import 'package:flutter/material.dart';

import '../../../api/api.dart';
import '../../../shared/ui/colors.dart';

class AvatarLetterIcon extends StatelessWidget {
  const AvatarLetterIcon({
    required this.name,
    this.lastName,
    super.key,
    this.size = const Size(55, 60),
    this.borderRadius = 5.0,
    this.padding = const EdgeInsets.all(4.0),
    this.backgroundColor = black,
    this.textColor = dullGray,
    this.avatar,
    this.isDeleted,
  });

  /// The text that will be used for the icon. It is truncated to 2 characters.
  final String name;
  final String? lastName;
  final Size size;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color textColor;
  final Avatar? avatar;
  final bool? isDeleted;

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
      padding: padding,
      height: size.height,
      width: size.width,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: avatar?.imageUrl != null
              ? Image.network(
                  avatar!.imageUrl!,
                  height: size.height,
                  width: size.width,
                  fit: BoxFit.cover,
                )
              : isDeleted ?? false
                  ? const Icon(
                      Icons.person_off_outlined,
                      size: 30.0,
                    )
                  : Text(
                      getText(),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: textColor,
                          fontSize: size.height / 2.7),
                    ),
        ),
      ),
    );
  }
}
