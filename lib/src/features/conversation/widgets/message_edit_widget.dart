import 'package:flutter/material.dart';

import '../../../shared/ui/colors.dart';

class MessageEditWidget extends StatelessWidget {
  final bool isOwn;

  const MessageEditWidget({super.key, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Text("Edited",
          style: TextStyle(color: isOwn ? white : dullGray, fontSize: 12.0)),
      const Padding(
        padding: EdgeInsets.only(
          left: 4,
        ),
        child: SizedBox.square(dimension: 15.0),
      )
    ]);
  }
}
