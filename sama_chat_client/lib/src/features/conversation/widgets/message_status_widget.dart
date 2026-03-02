import 'package:flutter/material.dart';
import '../../../db/models/message_model.dart';
import '../../../shared/ui/colors.dart';

class MessageStatusWidget extends StatelessWidget {
  final MessageModelStatus status;

  const MessageStatusWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageModelStatus.read:
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
      case MessageModelStatus.sent:
        return const Stack(children: <Widget>[
          Icon(Icons.check_rounded, size: 15.0, color: lightMallow),
          Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: SizedBox.square(dimension: 15.0),
          )
        ]);
      case MessageModelStatus.pending:
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
