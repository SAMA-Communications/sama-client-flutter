import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/attachments/attachments_repository.dart';
import '../../models/models.dart';

part 'images_attachment_event.dart';

part 'images_attachment_state.dart';

class ImagesAttachmentBloc
    extends Bloc<ImagesAttachmentEvent, ImagesAttachmentState> {
  final ChatMessage message;
  final AttachmentsRepository attachmentsRepository;

  ImagesAttachmentBloc({
    required this.message,
    required this.attachmentsRepository,
  }) : super(const ImagesAttachmentState()) {
    on<_AttachmentsUrlsReceived>(
      _onAttachmentsUrlsReceived,
    );

    _requestAttachmentsUrls();
  }

  FutureOr<void> _onAttachmentsUrlsReceived(
      _AttachmentsUrlsReceived event, Emitter<ImagesAttachmentState> emit) {
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
