import 'package:flutter/material.dart';

import '../ui/colors.dart';

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

class CenterLoader extends StatelessWidget {
  const CenterLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 44,
        width: 44,
        child: CircularProgressIndicator(strokeWidth: 3.5),
      ),
    );
  }
}

class TitleLoader extends StatelessWidget {
  final Color color;
  final Widget title;

  const TitleLoader(this.color, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        Transform.scale(
            scale: 0.75,
            child: CircularProgressIndicator(color: color, strokeWidth: 3.0)),
        title
      ],
    );
  }
}
