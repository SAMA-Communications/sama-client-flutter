import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

import '../../../db/models/conversation_model.dart';
import '../../../repository/messages/messages_repository.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/utils/media_utils.dart';
import '../bloc/media_sender/media_sender_bloc.dart';

class MediaSender extends StatelessWidget {
  const MediaSender({super.key});

  static Widget create({
    Key? key,
    required ConversationModel currentConversation,
  }) {
    return BlocProvider<MediaSenderBloc>(
      create: (context) => MediaSenderBloc(
          currentConversation: currentConversation,
          messagesRepository:
              RepositoryProvider.of<MessagesRepository>(context)),
      child: MediaSender(
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaSenderBloc, MediaSenderState>(
      listener: (context, state) {
        if (state.status == MediaSelectorStatus.processingFinished ||
            state.status == MediaSelectorStatus.canceled) {
          context.pop();
        }
      },
      child: BlocBuilder<MediaSenderBloc, MediaSenderState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'Send attachment',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (state.selectedFiles.isEmpty &&
                        state.status == MediaSelectorStatus.initial)
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 48,
                        height: 48,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3.0,
                        ),
                      ),
                    if (state.selectedFiles.isEmpty &&
                        state.status != MediaSelectorStatus.initial)
                      const Center(
                        child: Text(
                          'Select files',
                          style: TextStyle(color: dullGray, fontSize: 16),
                        ),
                      ),
                    if (state.selectedFiles.isNotEmpty)
                      _buildPreviewGrid(state.status, state.selectedFiles,
                          state.progressStream),
                    if (state.selectedFiles.isNotEmpty &&
                        state.status == MediaSelectorStatus.picking)
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 48,
                        height: 48,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3.0,
                        ),
                      ),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 120.0,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        color: gainsborough,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: const TextStyle(fontSize: 15.0),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: dullGray),
                        ),
                        onChanged: (text) {
                          BlocProvider.of<MediaSenderBloc>(context)
                              .add(ChangeMessage(text));
                        },
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            if (state.selectedFiles.length < 10 &&
                                state.status !=
                                    MediaSelectorStatus.processing) {
                              BlocProvider.of<MediaSenderBloc>(context)
                                  .add(const PickMoreFiles());
                            }
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(
                                color: state.selectedFiles.length < 10 &&
                                        state.status !=
                                            MediaSelectorStatus.processing
                                    ? slateBlue
                                    : whiteAluminum),
                          ),
                        ),
                        const Expanded(child: SizedBox.shrink()),
                        TextButton(
                            onPressed: () {
                              BlocProvider.of<MediaSenderBloc>(context)
                                  .add(const CancelSelection());
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: slateBlue),
                            )),
                        TextButton(
                          onPressed: () {
                            if (state.selectedFiles.isNotEmpty &&
                                state.status !=
                                    MediaSelectorStatus.processing) {
                              BlocProvider.of<MediaSenderBloc>(context)
                                  .add(const SendMessage());
                            }
                          },
                          child: Text(
                            'Send',
                            style: TextStyle(
                                color: state.selectedFiles.isNotEmpty &&
                                        state.status !=
                                            MediaSelectorStatus.processing
                                    ? slateBlue
                                    : whiteAluminum),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: state.error.isNotEmpty,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                      color: red.withAlpha(200),
                    ),
                    child: Text(
                      state.error,
                      style: const TextStyle(
                          color: white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildPreviewGrid(
  MediaSelectorStatus status,
  List<File> selectedFiles,
  Stream<MapEntry<String, int>> progressStream,
) {
  return GridView.custom(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverQuiltedGridDelegate(
      crossAxisCount: 4,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      repeatPattern: QuiltedGridRepeatPattern.inverted,
      pattern: getGridPatternForCount(selectedFiles.length),
    ),
    childrenDelegate: SliverChildBuilderDelegate(
      childCount: selectedFiles.length,
      (context, index) => _buildPreviewItem(
        context,
        status,
        selectedFiles[index],
        progressStream,
      ),
    ),
  );
}

Widget _buildPreviewItem(
  BuildContext context,
  MediaSelectorStatus status,
  File file,
  Stream<MapEntry<String, int>> progressStream,
) {
  return ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(6)),
    child: isImage(file.path) || isVideo(file.path)
        ? Stack(
            alignment: Alignment.center,
            children: [
              FutureBuilder<File>(
                future: isImage(file.path)
                    ? Future.value(file)
                    : getVideoThumbnail(file),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.file(
                      height: double.infinity,
                      width: double.infinity,
                      snapshot.data!,
                      fit: BoxFit.cover,
                      cacheHeight: 480,
                    );
                  } else if (snapshot.hasError) {
                    return const Text('⚠️');
                  } else {
                    return const CircularProgressIndicator(
                      color: slateBlue,
                      strokeWidth: 3,
                    );
                  }
                },
              ),
              if (status == MediaSelectorStatus.processing)
                Align(
                  alignment: Alignment.center,
                  child: StreamBuilder(
                      stream: progressStream
                          .where((data) => data.key == basename(file.path)),
                      builder: (context, snapshot) {
                        return CircularProgressIndicator(
                          color: slateBlue,
                          strokeWidth: 3,
                          value: snapshot.hasData
                              ? snapshot.data!.value / 100
                              : null,
                        );
                      }),
                ),
              if (isVideo(file.path))
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: black.withAlpha(150),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FutureBuilder<double?>(
                                future: getVideoDuration(file),
                                builder: (context, snapshot) {
                                  String stringDuration = '--:--';

                                  if (snapshot.hasData) {
                                    stringDuration = formatHHMMSS(
                                        (snapshot.data! / 1000).toInt());
                                  }

                                  return Text(
                                    stringDuration,
                                    style: const TextStyle(
                                        color: white, fontSize: 12),
                                  );
                                }),
                            const Icon(
                              Icons.video_file,
                              color: white,
                              size: 12,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: black.withAlpha(150),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: status == MediaSelectorStatus.processing
                        ? null
                        : () => BlocProvider.of<MediaSenderBloc>(context)
                            .add(RemoveFile(file)),
                    icon: const Icon(
                      Icons.close,
                      color: white,
                      size: 18,
                    ),
                  ),
                ),
              )
            ],
          )
        : const SizedBox.shrink(),
  );
}
