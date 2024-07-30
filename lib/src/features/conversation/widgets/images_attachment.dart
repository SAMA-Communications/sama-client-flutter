import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../repository/attachments/attachments_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/utils/media_utils.dart';
import '../bloc/images_attachment/images_attachment_bloc.dart';
import '../models/chat_attachment.dart';
import '../models/models.dart';
import 'message_bubble.dart';

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
          return Stack(alignment: Alignment.bottomRight, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagesGrid(
                    message.attachments!
                        .map((attachment) => attachment
                            .toChatAttachment(state.urls[attachment.fileId]))
                        .toList(),
                    state.urls),
                if (message.body?.isNotEmpty ?? false) ...[
                  Text(
                    message.body ?? '',
                    style: TextStyle(
                        color: message.isOwn ? white : black, fontSize: 16.0),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      dateToTime(DateTime.fromMillisecondsSinceEpoch(
                          message.t! * 1000)),
                      style: TextStyle(
                          color: message.isOwn ? white : dullGray,
                          fontSize: 12.0),
                    ),
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
                    child: Text(
                      dateToTime(DateTime.fromMillisecondsSinceEpoch(
                          message.t! * 1000)),
                      style: const TextStyle(color: white),
                    ),
                  ),
                ),
              ),
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
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      repeatPattern: QuiltedGridRepeatPattern.inverted,
      pattern: getGridPatternForCount(attachments.length),
    ),
    childrenDelegate: SliverChildBuilderDelegate(
      childCount: attachments.length,
      (context, index) => _buildImageItem(attachments[index]),
    ),
  );
}

Widget _buildImageItem(ChatAttachment attachment) {
  return GestureDetector(
    onTap: () {
      launchUrl(Uri.parse(attachment.url!));
    },
    child: AbsorbPointer(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: isImage(attachment.fileName!)
            ? CachedNetworkImage(
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(slateBlue),
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
              )
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
