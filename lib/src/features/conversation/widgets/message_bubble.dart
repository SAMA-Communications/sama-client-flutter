import 'package:flutter/cupertino.dart';

import '../../../api/users/models/models.dart';
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
    return Row(
      mainAxisAlignment:
          isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isFirst && !isOwn)
          AvatarLetterIcon(
            name: getUserName(sender),
            lastName: sender.lastName,
            size: const Size(40, 40),
            borderRadius: 16,
            backgroundColor: isOwn ? slateBlue : gainsborough,
          ),
        if (!isFirst && !isOwn)
          const SizedBox(
            width: 40,
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            decoration: BoxDecoration(
              color: isOwn ? slateBlue : gainsborough,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomRight: isFirst
                      ? isOwn
                          ? const Radius.circular(0)
                          : const Radius.circular(8)
                      : const Radius.circular(8),
                  bottomLeft: isFirst
                      ? isOwn
                          ? const Radius.circular(8)
                          : const Radius.circular(0)
                      : const Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLast && !isOwn)
                    Text(
                      getUserName(sender),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOwn ? gainsborough : slateBlue,
                      ),
                    ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
