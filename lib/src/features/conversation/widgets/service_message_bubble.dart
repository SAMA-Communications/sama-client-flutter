import 'package:flutter/cupertino.dart';

import '../../../shared/ui/colors.dart';

class ServiceMessageBubble extends StatelessWidget {
  final Widget child;

  const ServiceMessageBubble({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          color: gainsborough,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 4.0),
        padding: const EdgeInsets.all(6.0),
        child: child,
      ),
    );
  }
}
