import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/attachments/attachments_repository.dart';
import '../../models/models.dart';

part 'media_attachment_event.dart';

part 'media_attachment_state.dart';

class MediaAttachmentBloc
    extends Bloc<MediaAttachmentEvent, MediaAttachmentState> {
  final ChatMessage message;
  final AttachmentsRepository attachmentsRepository;

  MediaAttachmentBloc({
    required this.message,
    required this.attachmentsRepository,
  }) : super(const MediaAttachmentState()) {
    on<_AttachmentsUrlsReceived>(
      _onAttachmentsUrlsReceived,
    );

    _requestAttachmentsUrls();
  }

  FutureOr<void> _onAttachmentsUrlsReceived(
      _AttachmentsUrlsReceived event, Emitter<MediaAttachmentState> emit) {
    emit(state.copyWith(urls: Map.from(event.urls)));
  }

  void _requestAttachmentsUrls() {
    if (message.attachments?.isNotEmpty ?? false) {
      Set<String> ids =
          message.attachments!.map((attachment) => attachment.fileId!).toSet();

      attachmentsRepository.getFilesUrls(ids).then((urls) {
        add(_AttachmentsUrlsReceived(Map.from(urls)));
      });
    }
  }
}
