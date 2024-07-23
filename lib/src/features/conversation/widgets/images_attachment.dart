import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../repository/attachments/attachments_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../bloc/images_attachment/images_attachment_bloc.dart';
import '../models/chat_attachment.dart';
import '../models/models.dart';
import 'message_bubble.dart';
import 'text_message.dart';

class ImagesAttachment extends StatelessWidget {
  final ChatMessage message;

  const ImagesAttachment({super.key, required this.message});

  static Widget create({Key? key, required ChatMessage message}) {
    return BlocProvider<ImagesAttachmentBloc>(
      create: (context) => ImagesAttachmentBloc(
          message: message,
          attachmentsRepository:
              RepositoryProvider.of<AttachmentsRepository>(context)),
      child: ImagesAttachment(
        key: key,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      sender: message.sender,
      isFirst: message.isFirstUserMessage,
      isLast: message.isLastUserMessage,
      isOwn: message.isOwn,
      child: BlocBuilder<ImagesAttachmentBloc, ImagesAttachmentState>(
        builder: (context, state) {
          return Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildImagesGrid(
                  message.attachments!
                      .map((attachment) => attachment
                          .toChatAttachment(state.urls[attachment.fileId]))
                      .toList(),
                  state.urls),
              if (message.body?.isNotEmpty ?? false)
                TextMessage(
                  body: message.body ?? '',
                  style: TextStyle(
                      color: message.isOwn ? white : black, fontSize: 16.0),
                  time: Text(
                    dateToTime(
                        DateTime.fromMillisecondsSinceEpoch(message.t! * 1000)),
                    style: TextStyle(
                        color: message.isOwn ? white : dullGray,
                        fontSize: 12.0),
                  ),
                ),
            ]),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: black.withAlpha(150),
                    child: Text(
                      dateToTime(DateTime.fromMillisecondsSinceEpoch(
                          message.t! * 1000)),
                      style: const TextStyle(color: white),
                    ),
                  ),
                ),
              ),
            )
          ]);
        },
      ),
    );
  }
}

Widget _buildImagesGrid(
    List<ChatAttachment> attachments, Map<String, String> urls) {
  return GridView.custom(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverQuiltedGridDelegate(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      repeatPattern: QuiltedGridRepeatPattern.inverted,
      pattern: _getPattenForCount(attachments.length),
    ),
    childrenDelegate: SliverChildBuilderDelegate(
      childCount: attachments.length,
      (context, index) => _buildImageItem(attachments[index]),
    ),
  );
}

Widget _buildImageItem(ChatAttachment attachment) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(
        Radius.circular(8.0),
      ),
      border: Border.all(
        color: white,
        width: 2.0, // Adjust width as needed
      ),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: CachedNetworkImage(
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        maxHeightDiskCache: 300,
        maxWidthDiskCache: 300,
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
              : BlurHash(
                  hash: attachment.fileBlurHash!,
                  imageFit: BoxFit.cover,
                ),
        ),
        errorWidget: (context, url, error) => Center(
          child: !validateBlurhash(attachment.fileBlurHash ?? '')
              ? const SizedBox.shrink()
              : BlurHash(
                  hash: attachment.fileBlurHash!,
                  imageFit: BoxFit.cover,
                ),
        ),
        imageUrl: attachment.url ?? '',
        fit: BoxFit.cover,
      ),
    ),
  );
}

List<QuiltedGridTile> _getPattenForCount(int count) {
  switch (count) {
    case 1:
      return [
        const QuiltedGridTile(4, 4),
      ];

    case 2:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(3, 2),
      ];
    case 3:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(2, 2),
      ];
    case 4:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(2, 2),
      ];

    case 5:
    case 0:
      return [
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 2),
      ];

    case 6:
      return _getPattenForCount(3);

    case 7:
      return [
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 2),
      ];

    case 8:
      return _getPattenForCount(4);
    case 9:
      return [..._getPattenForCount(5), ..._getPattenForCount(4)];
  }

  return _getPattenForCount(count ~/ 10);
}
