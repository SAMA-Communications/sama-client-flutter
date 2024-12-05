import 'package:flutter/material.dart';
import '../../../shared/ui/colors.dart';
import '../models/chat_message.dart';

class MessageStatusWidget extends StatelessWidget {
  final ChatMessageStatus status;

  const MessageStatusWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChatMessageStatus.read:
        return const Stack(children: <Widget>[
          Icon(
            Icons.check_rounded,
            size: 15.0,
            color: lightMallow,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: Icon(Icons.check_rounded, size: 15.0, color: lightMallow),
          )
        ]);
      case ChatMessageStatus.sent:
        return const Stack(children: <Widget>[
          Icon(Icons.check_rounded, size: 15.0, color: lightMallow),
          Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: SizedBox.square(dimension: 15.0),
          )
        ]);
      case ChatMessageStatus.pending:
        return const Stack(children: <Widget>[
          Icon(Icons.watch_later_outlined, size: 15.0, color: lightMallow),
          Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: SizedBox.square(dimension: 15.0),
          )
        ]);
      default:
        return const Stack(children: <Widget>[
          SizedBox.square(dimension: 15.0),
          Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: SizedBox.square(dimension: 15.0),
          )
        ]);
    }
  }
}
