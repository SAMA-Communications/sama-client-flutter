import 'package:flutter/material.dart';

class VerticalLineWidget extends StatelessWidget {
  const VerticalLineWidget({
    super.key,
    this.leftPadding = 0,
    this.rightPadding = 0,
    this.verticalBarColor,
    this.verticalBarWidth,
  });

  final Color? verticalBarColor;
  final double leftPadding;
  final double rightPadding;
  final double? verticalBarWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: verticalBarWidth ?? 2.5,
      color: verticalBarColor ?? Colors.grey.shade300,
      margin: EdgeInsets.only(
        left: leftPadding,
        right: rightPadding,
      ),
    );
  }
}