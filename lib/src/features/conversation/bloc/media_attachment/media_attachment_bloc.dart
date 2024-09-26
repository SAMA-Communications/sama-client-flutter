import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/attachments/attachments_repository.dart';
import '../../models/models.dart';

part 'media_attachment_event.dart';

part 'media_attachment_state.dart';

class MediaAttachmentBloc
    extends Bloc<MediaAttachmentEvent, MediaAttachmentState> {
  final AttachmentsRepository attachmentsRepository;

  MediaAttachmentBloc({
    required this.attachmentsRepository,
  }) : super(const MediaAttachmentState()) {
    on<AttachmentsUrlsRequested>(
      _onAttachmentsUrlsRequested,
    );
    on<_AttachmentsUrlsReceived>(
      _onAttachmentsUrlsReceived,
    );
  }

  FutureOr<void> _onAttachmentsUrlsRequested(
      AttachmentsUrlsRequested event, Emitter<MediaAttachmentState> emit) {
    _requestAttachmentsUrls(event.message);
  }

  FutureOr<void> _onAttachmentsUrlsReceived(
      _AttachmentsUrlsReceived event, Emitter<MediaAttachmentState> emit) {
    Map<String, String> urls = Map.from(state.urls)..addAll(event.urls);
    emit(state.copyWith(urls: urls));
  }

  void _requestAttachmentsUrls(ChatMessage message) {
    if (message.attachments?.isNotEmpty ?? false) {
      Set<String> ids =
          message.attachments!.map((attachment) => attachment.fileId!).toSet();

      attachmentsRepository.getFilesUrls(ids).then((urls) {
        add(_AttachmentsUrlsReceived(Map.from(urls)));
      });
    }
  }
}
