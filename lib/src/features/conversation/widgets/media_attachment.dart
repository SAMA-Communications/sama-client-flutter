import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../db/models/attachment_model.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/utils/media_utils.dart';
import '../bloc/media_attachment/media_attachment_bloc.dart';
import '../models/models.dart';
import 'message_bubble.dart';
import 'message_status_widget.dart';

class MediaAttachment extends StatelessWidget {
  final ChatMessage message;

  const MediaAttachment({super.key, required this.message});

  static Widget create({Key? key, required ChatMessage message}) {
    return MediaAttachment(
      key: key,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      sender: message.sender,
      isFirst: message.isFirstUserMessage,
      isLast: message.isLastUserMessage,
      isOwn: message.isOwn,
      child: BlocBuilder<MediaAttachmentBloc, MediaAttachmentState>(
        builder: (context, state) {
          if (message.attachments.first.url == null) {
            context
                .read<MediaAttachmentBloc>()
                .add(AttachmentsUrlsRequested(message));
          }
          return Stack(alignment: Alignment.bottomRight, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMediaGrid(message.attachments),
                if (message.body?.isNotEmpty ?? false) ...[
                  Text(
                    message.body ?? '',
                    style: TextStyle(
                        color: message.isOwn ? white : black, fontSize: 16.0),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Wrap(
                        spacing: 4.0,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            dateToTime(DateTime.fromMillisecondsSinceEpoch(
                                message.t! * 1000)),
                            style: TextStyle(
                                color: message.isOwn ? white : dullGray,
                                fontSize: 12.0),
                          ),
                          MessageStatusWidget(status: message.status),
                        ]),
                  ),
                ]
              ],
            ),
            if (message.body?.isEmpty ?? true)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: black.withAlpha(150),
                    child: Wrap(
                        spacing: 4.0,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            dateToTime(DateTime.fromMillisecondsSinceEpoch(
                                message.t! * 1000)),
                            style: const TextStyle(color: white),
                          ),
                          MessageStatusWidget(status: message.status),
                        ]),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

Widget _buildMediaGrid(List<AttachmentModel> attachments) {
  return GridView.custom(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverQuiltedGridDelegate(
      crossAxisCount: 4,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      repeatPattern: QuiltedGridRepeatPattern.inverted,
      pattern: getGridPatternForCount(attachments.length),
    ),
    childrenDelegate: SliverChildBuilderDelegate(
      childCount: attachments.length,
      (context, index) =>
          _buildMediaAttachmentItem(context, attachments[index]),
    ),
  );
}

Widget _buildMediaAttachmentItem(AttachmentModel attachment) {
  return GestureDetector(
    onTap: () {
      launchUrl(Uri.parse(attachment.url!));
    },
    child: AbsorbPointer(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: isImage(attachment.fileName!) || isVideo(attachment.fileName!)
            ? _buildMediaItem(attachment)
            : Container(
                color: white,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(text: '⚠️\n'),
                        if (attachment.url != null) ...[
                          const TextSpan(
                              text: 'See content by',
                              style: TextStyle(color: dullGray, fontSize: 10)),
                          const TextSpan(
                            text: ' link ',
                            style: TextStyle(color: slateBlue, fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ),
  );
}

Widget _buildMediaItem(AttachmentModel attachment) {
  return isImage(attachment.fileName!)
      ? buildImageItem(attachment)
      : buildVideoItem(attachment);
}

Widget buildImageItem(AttachmentModel attachment) {
  return CachedNetworkImage(
    fadeInDuration: const Duration(milliseconds: 300),
    fadeOutDuration: const Duration(milliseconds: 100),
    maxHeightDiskCache: 600,
    maxWidthDiskCache: 600,
    placeholder: (context, url) => Center(
      child: !validateBlurhash(attachment.fileBlurHash ?? '')
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(slateBlue),
              ),
            )
          : SizedBox.expand(
              child: Image(
                image: BlurHashImage(attachment.fileBlurHash!),
                fit: BoxFit.cover,
              ),
            ),
    ),
    errorWidget: (context, url, error) => Center(
      child: !validateBlurhash(attachment.fileBlurHash ?? '')
          ? const SizedBox.shrink()
          : SizedBox.expand(
              child: Image(
                image: BlurHashImage(attachment.fileBlurHash!),
                fit: BoxFit.cover,
              ),
            ),
    ),
    imageUrl: attachment.url ?? '',
    fit: BoxFit.cover,
  );
}

Widget buildVideoItem(AttachmentModel attachment) {
  Widget videoBackground = Container(
    color: white,
  );

  if (validateBlurhash(attachment.fileBlurHash ?? '')) {
    videoBackground = BlurHash(
      hash: attachment.fileBlurHash!,
      imageFit: BoxFit.cover,
    );
  }

  Widget? videoPreview;

  if (attachment.url?.isNotEmpty ?? false) {
    videoPreview = FutureBuilder(
        future: getVideoThumbnailByUrl(attachment.url!, attachment.fileId!),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          return Image.file(
            width: double.maxFinite,
            height: double.maxFinite,
            File(snapshot.data!),
            fit: BoxFit.cover,
            cacheHeight: 400,
          );
        });
  }

  return Stack(
    children: [
      videoBackground,
      if (videoPreview != null) videoPreview,
      Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.all(2.0),
          alignment: Alignment.center,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: black.withAlpha(150),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: white,
            size: 28,
          ),
        ),
      ),
      Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: Container(
              padding: const EdgeInsets.all(4),
              color: black.withAlpha(150),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TODO VT temporary hide duration widget before implementing required fields on the back-end
                  // FutureBuilder<double?>(
                  //     future: getVideoDurationByUrl(attachment.url ?? ''),
                  //     builder: (context, snapshot) {
                  //       String stringDuration = '--:--';
                  //
                  //       if (snapshot.hasData) {
                  //         stringDuration =
                  //             formatHHMMSS((snapshot.data! / 1000).toInt());
                  //       }
                  //
                  //       return Text(
                  //         stringDuration,
                  //         style: const TextStyle(color: white, fontSize: 12),
                  //       );
                  //     }),
                  Icon(
                    Icons.videocam_rounded,
                    color: white,
                    size: 16,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
