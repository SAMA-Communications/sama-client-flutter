import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../db/models/attachment_model.dart';
import '../../../../repository/attachments/attachments_repository.dart';
import '../../models/models.dart';

part 'media_attachment_event.dart';

part 'media_attachment_state.dart';

class MediaAttachmentBloc
    extends Bloc<MediaAttachmentEvent, MediaAttachmentState> {
  final AttachmentsRepository attachmentsRepository;

  MediaAttachmentBloc({required this.attachmentsRepository})
      : super(const MediaAttachmentState()) {
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
    if (message.attachments.isNotEmpty) {
      Set<String> ids =
          message.attachments.map((attachment) => attachment.fileId!).toSet();

      var attachments = <AttachmentModel>[];
      attachmentsRepository.getFilesUrls(ids).then((urls) async {
        urls.forEach((id, url) {
          var attachment = message.attachments
              .firstWhere((o) => o.fileId == id)
              .copyWith(url: url);

          attachments.add(attachment);
        });
        message.attachments.clear();
        message.attachments.applyToDb();
        message.attachments.addAll(attachments);

        await attachmentsRepository.updateAttachmentsLocal(attachments);

        add(_AttachmentsUrlsReceived(Map.from(urls)));
      });
    }
  }
}
