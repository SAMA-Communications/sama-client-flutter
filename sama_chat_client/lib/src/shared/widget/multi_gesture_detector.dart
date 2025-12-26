import 'package:flutter/material.dart';

class MultiGestureDetector extends StatelessWidget {
  const MultiGestureDetector({
    super.key,
    this.child,
    this.onTap,
    this.taps = 1,
  });

  final Widget? child;
  final int taps;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    int lastTap = DateTime.now().millisecondsSinceEpoch;
    int consecutiveTaps = 0;

    return GestureDetector(
      onTap: () {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (now - lastTap < 500) {
          if (++consecutiveTaps == taps) {
            onTap?.call();
          }
        } else {
          consecutiveTaps = 1;
        }
        lastTap = now;
      },
      child: child,
    );
  }
}
