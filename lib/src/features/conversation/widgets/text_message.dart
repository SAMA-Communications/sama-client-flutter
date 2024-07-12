import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  final String body;
  final TextStyle style;
  final Widget time;
  final Widget? status;

  const TextMessage({
    super.key,
    required this.body,
    required this.style,
    required this.time,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          body,
          style: style,
        ),
        time,
        if (status != null) status!,
      ],
    );
  }
}
