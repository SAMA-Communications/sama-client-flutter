part of 'images_attachment_bloc.dart';

class ImagesAttachmentEvent extends Equatable {
  const ImagesAttachmentEvent();

  @override
  List<Object> get props => [];
}

final class AttachmentsUrlsRequested extends ImagesAttachmentEvent {
  final ChatMessage message;

  const AttachmentsUrlsRequested(this.message);
}

final class _AttachmentsUrlsReceived extends ImagesAttachmentEvent {
  final Map<String, String> urls;

  const _AttachmentsUrlsReceived(this.urls);
}
