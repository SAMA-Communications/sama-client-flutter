import 'package:flutter/cupertino.dart';

import '../../../api/api.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';

class MessageBubble extends StatelessWidget {
  final User sender;
  final bool isFirst;
  final bool isLast;
  final bool isOwn;
  final Widget child;

  const MessageBubble({
    super.key,
    required this.child,
    required this.sender,
    required this.isFirst,
    required this.isLast,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isLast && !isOwn)
            AvatarLetterIcon(
              name: getUserName(sender),
              lastName: sender.lastName,
              size: const Size(40.0, 40.0),
              borderRadius: 16.0,
              backgroundColor: isOwn ? slateBlue : gainsborough,
            ),
          if (!isLast && !isOwn)
            const SizedBox(
              width: 40,
            ),
          Flexible(
            child: CustomPaint(
              painter: CustomChatBubble(
                  color: isOwn ? slateBlue : gainsborough,
                  isOwn: isOwn,
                  withTail: isLast),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirst && !isOwn)
                        Text(
                          getUserName(sender),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOwn ? gainsborough : slateBlue,
                          ),
                        ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300.0),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomChatBubble extends CustomPainter {
  final Color color;
  final bool isOwn;
  final bool withTail;

  CustomChatBubble(
      {required this.color, required this.isOwn, required this.withTail});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    Path paintBubbleTail() {
      if (isOwn) {
        return Path()
          ..moveTo(size.width - 15, size.height - 0)
          ..quadraticBezierTo(
              size.width - 10, size.height, size.width + 6, size.height - 0)
          ..quadraticBezierTo(size.width - 5, size.height - 5, size.width - 10,
              size.height - 16);
      } else {
        return Path()
          ..moveTo(17, size.height - 0)
          ..quadraticBezierTo(7, size.height, -4, size.height - 0)
          ..quadraticBezierTo(7, size.height - 5, 12, size.height - 16);
      }
    }

    final RRect bubbleBody = RRect.fromRectAndRadius(
        Rect.fromLTWH(isOwn ? -8 : 8, 0, size.width, size.height),
        const Radius.circular(8));

    canvas.drawRRect(bubbleBody, paint);

    if (withTail) {
      final Path bubbleTail = paintBubbleTail();
      canvas.drawPath(bubbleTail, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
