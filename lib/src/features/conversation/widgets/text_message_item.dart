import 'package:flutter/material.dart';

import '../../../db/models/models.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../models/models.dart';
import 'message_bubble.dart';
import 'message_status_widget.dart';
import 'text_message.dart';

class TextMessageItem extends StatelessWidget {
  final ChatMessage message;

  const TextMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      sender: message.sender.toUserModel(),
      isFirst: message.isFirstUserMessage,
      isLast: message.isLastUserMessage,
      isOwn: message.isOwn,
      child: TextMessage(
        body: message.body ?? '',
        style: TextStyle(color: message.isOwn ? white : black, fontSize: 16.0),
        linkStyle:
            TextStyle(color: message.isOwn ? gold : slateBlue, fontSize: 16.0),
        time: Text(
          dateToTime(DateTime.fromMillisecondsSinceEpoch(message.t! * 1000)),
          style: TextStyle(
              color: message.isOwn ? white : dullGray, fontSize: 12.0),
        ),
        status: MessageStatusWidget(status: message.status),
      ),
    );
  }
}
