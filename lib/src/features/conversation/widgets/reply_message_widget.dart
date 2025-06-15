import 'package:flutter/material.dart';

import '../../../shared/ui/colors.dart';
import '../models/chat_message.dart';

const double horizontalPadding = 8;
const double replyBorderRadius1 = 30;
const double replyBorderRadius2 = 18;

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  /// Provides message instance of chat.
  final ChatMessage message;

  /// Provides call back when user taps on replied message.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final replyBySender = message.isOwn;
    final textTheme = Theme
        .of(context)
        .textTheme;
    final replyMessage = message;
    final replyBy = 'replyByNAME';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            horizontalPadding, 8, horizontalPadding, 4),
        // constraints:
        // const BoxConstraints(maxWidth: 280),
        child: Column(
      crossAxisAlignment:
      replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            'Replied by $replyBy',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, letterSpacing: 0.3),
          ),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: replyBySender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!replyBySender)
                  const ReplyLine(
                    rightPadding: 4,
                  ),
                Flexible(
                  child: Opacity(
                    opacity: 0.8,
                    child: message.isHasAttachments()
                        ? Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              replyMessage.attachments.first.url ?? ''),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    )
                        : Container(
                      // constraints: BoxConstraints(
                      //   maxWidth: 280,
                      // ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: _borderRadius(
                          replyMessage: replyMessage.body!,
                          replyBySender: replyBySender,
                        ),
                        color: message.isOwn ? lightMallow : smokyBorough,
                      ),
                      child: Text(replyMessage.body!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: textTheme.bodyMedium!.copyWith(
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
                if (replyBySender)
                  ReplyLine(
                    leftPadding: 4,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) =>
      replyBySender
          ?
      (replyMessage.length < 37
          ? BorderRadius.circular(replyBorderRadius1)
          : BorderRadius.circular(replyBorderRadius2))
          :
      (replyMessage.length < 29
          ? BorderRadius.circular(replyBorderRadius1)
          : BorderRadius.circular(replyBorderRadius2));
}

class ReplyLine extends StatelessWidget {
  const ReplyLine({
    super.key,
    this.leftPadding = 0,
    this.rightPadding = 0,
    this.verticalBarColor,
    this.verticalBarWidth,
  });

  final Color? verticalBarColor;
  final double leftPadding;
  final double rightPadding;
  final double? verticalBarWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: verticalBarWidth ?? 2.5,
      color: verticalBarColor ?? Colors.grey.shade300,
      margin: EdgeInsets.only(
        left: leftPadding,
        right: rightPadding,
      ),
    );
  }
}