part of 'media_attachment_bloc.dart';

class MediaAttachmentEvent extends Equatable {
  const MediaAttachmentEvent();

  @override
  List<Object> get props => [];
}

final class AttachmentsUrlsRequested extends MediaAttachmentEvent {
  final MessageModel message;

  const AttachmentsUrlsRequested(this.message);
}

final class _AttachmentsUrlsReceived extends MediaAttachmentEvent {
  final Map<String, String> urls;

  const _AttachmentsUrlsReceived(this.urls);
}
