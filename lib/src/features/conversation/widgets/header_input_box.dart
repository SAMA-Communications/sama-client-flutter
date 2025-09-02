import 'package:flutter/material.dart';

import '../../../db/models/message_model.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/widget/vertical_line.dart';

class HeaderInputBox extends StatelessWidget {
  final MessageModel message;
  final String title;
  final VoidCallback? onTap;
  final Widget icon;

  const HeaderInputBox(
      {super.key,
      required this.message,
      required this.title,
      required this.onTap,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: gainsborough,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          const VerticalLine(
            rightPadding: 10,
            leftPadding: 10,
            verticalBarColor: slateBlue,
          ),
          Expanded(
            // add this
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: slateBlue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                    ),
                    IconButton(
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      alignment: Alignment.topRight,
                      // padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      icon: const Icon(
                        Icons.close,
                        color: black,
                        size: 20,
                      ),
                      onPressed: onTap,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: MessageView(
                    message: message,
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    if (message.attachments.isNotEmpty) {
      return const Row(
        children: [
          Icon(
            Icons.photo,
            size: 20,
            color: dullGray,
          ),
          Text(
            'attachment',
            style: TextStyle(
              color: black,
            ),
          ),
        ],
      );
    } else {
      return Text(
        message.body!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: black,
        ),
      );
    }
  }
}
