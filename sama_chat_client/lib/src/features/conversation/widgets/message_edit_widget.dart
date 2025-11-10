import 'package:flutter/material.dart';

import '../../../shared/ui/colors.dart';

class MessageEditWidget extends StatelessWidget {
  final bool isOwn;

  const MessageEditWidget({super.key, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Text("edited",
          style: TextStyle(
              color: isOwn ? gainsborough : dullGray, fontSize: 11.0)),
      const Padding(
        padding: EdgeInsets.only(
          left: 4,
        ),
        child: SizedBox.square(dimension: 15.0),
      )
    ]);
  }
}
