import 'package:flutter/cupertino.dart';

import '../../../db/entity_builder.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../models/models.dart';
import 'message_bubble.dart';
import 'text_message.dart';

class UnsupportedMessage extends StatelessWidget {
  final ChatMessage message;

  const UnsupportedMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      sender: buildWithUser(message.sender)!,
      isFirst: message.isFirstUserMessage,
      isLast: message.isLastUserMessage,
      isOwn: message.isOwn,
      child: TextMessage(
        body: '⚠️ Unsupported type of message',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: message.isOwn ? white : black,
        ),
        time: Text(
          dateToTime(DateTime.fromMillisecondsSinceEpoch(message.t! * 1000)),
          style: TextStyle(
              color: message.isOwn ? white : dullGray, fontSize: 12.0),
        ),
      ),
    );
  }
}
