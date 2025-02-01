import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../db/models/user_model.dart';
import '../../../navigation/constants.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/string_utils.dart';
import '../../conversations_list/widgets/avatar_letter_icon.dart';

class MessageBubble extends StatelessWidget {
  final UserModel sender;
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isLast && !isOwn)
            GestureDetector(
                onTap: () => context.push(userInfoPath, extra: sender),
                child:AvatarLetterIcon(
              name: getUserModelName(sender),
              lastName: sender.lastName,
              size: const Size(40.0, 40.0),
              backgroundColor: isOwn ? slateBlue : gainsborough,
              avatar: sender.avatar,
              isDeleted: isDeletedUserModel(sender),
            )),
          if (!isLast && !isOwn)
            const SizedBox(
              width: 40,
            ),
          CustomPaint(
            painter: CustomChatBubble(
                color: isOwn ? slateBlue : gainsborough,
                isOwn: isOwn,
                withTail: isLast),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: EdgeInsets.only(
                  left: isOwn ? 4.0 : 20.0,
                  right: isOwn ? 15.0 : 4.0,
                  top: 4.0,
                  bottom: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirst && !isOwn)
                    Text(
                      getUserModelName(sender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOwn ? gainsborough : slateBlue,
                      ),
                    ),
                  child,
                ],
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
