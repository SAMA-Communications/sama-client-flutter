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
            child: Container(
              margin: EdgeInsets.only(left: 8.0, right: isOwn ? 0.0 : 8.0),
              decoration: BoxDecoration(
                color: isOwn ? slateBlue : gainsborough,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isFirst ? 8.0 : 4.0),
                    topRight: Radius.circular(isFirst ? 8.0 : 4.0),
                    bottomRight: isLast
                        ? isOwn
                            ? const Radius.circular(0.0)
                            : const Radius.circular(8.0)
                        : const Radius.circular(4.0),
                    bottomLeft: isLast
                        ? isOwn
                            ? const Radius.circular(8.0)
                            : const Radius.circular(0.0)
                        : const Radius.circular(4.0)),
              ),
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
        ],
      ),
    );
  }
}
