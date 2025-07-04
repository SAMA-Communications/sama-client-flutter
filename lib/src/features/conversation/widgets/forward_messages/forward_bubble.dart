import 'package:flutter/material.dart';

import '../../../../shared/utils/string_utils.dart';
import '../../../../shared/widget/vertical_line_widget.dart';
import '../../models/chat_message.dart';

const double horizontalPadding = 8;

class ForwardBubble extends StatelessWidget {
  const ForwardBubble({
    super.key,
    required this.message,
    this.onTap,
  });

  final ChatMessage message;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isReplyBySender = message.isOwn;
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
              horizontalPadding, 4, horizontalPadding, 4),
          constraints: const BoxConstraints(maxWidth: 280),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: isReplyBySender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isReplyBySender)
                  Transform.scale(
                    scaleX: -1,
                    child: const Icon(Icons.forward_outlined),
                  ),
                const Text(
                  'Forwarded',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, letterSpacing: 0.3),
                ),
                if (isReplyBySender) const Icon(Icons.forward_outlined)
              ],
            ),
          ),
        ));
  }
}
