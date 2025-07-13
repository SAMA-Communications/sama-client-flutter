import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../db/models/attachment_model.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/media_utils.dart';
import '../../../shared/utils/string_utils.dart';
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

  final ChatMessage message;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final replyMessage = message.replyMessage;
    final isReplyBySender = message.isOwn;
    final replyTo = replyMessage?.from == null
        ? ''
        : message.sender.id == replyMessage?.from
            ? 'yourself'
            : getUserName(replyMessage?.sender);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            horizontalPadding, 8, horizontalPadding, 4),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: isReplyBySender
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              'Replied to $replyTo',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 14, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: isReplyBySender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isReplyBySender)
                    const ReplyLine(
                      rightPadding: 4,
                    ),
                  Flexible(
                    child: Opacity(
                      opacity: 0.8,
                      child: replyMessage?.hasAttachments() ?? false
                          ? _buildAttachmentWidget(
                              replyMessage!.attachments.first)
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: _borderRadius(
                                  replyMessage: replyMessage?.body ?? '',
                                  replyBySender: isReplyBySender,
                                ),
                                color:
                                    message.isOwn ? lightMallow : smokyBorough,
                              ),
                              child: Text(
                                replyMessage?.body ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: textTheme.bodyMedium!
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                    ),
                  ),
                  if (isReplyBySender)
                    const ReplyLine(
                      leftPadding: 4,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentWidget(AttachmentModel attachment) {
    var isImageType = isImage(attachment.fileName, attachment.contentType);

    return FutureBuilder(
        future: isImageType
            ? Future.value(attachment.url ?? '')
            : getVideoThumbnailByUrl(attachment.url!, attachment.fileId),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox(height: 40, width: 40);
          }
          return Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isImageType
                    ? CachedNetworkImageProvider(
                        snapshot.data!,
                        maxHeight: 50,
                        maxWidth: 50,
                      )
                    : FileImage(File(snapshot.data!)) as ImageProvider,
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        });
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) =>
      replyBySender
          ? (replyMessage.length < 37
              ? BorderRadius.circular(replyBorderRadius1)
              : BorderRadius.circular(replyBorderRadius2))
          : (replyMessage.length < 29
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
