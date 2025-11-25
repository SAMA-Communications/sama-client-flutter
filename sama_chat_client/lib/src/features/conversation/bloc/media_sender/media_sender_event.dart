part of 'media_sender_bloc.dart';

class MediaSenderEvent extends Equatable {
  const MediaSenderEvent();

  @override
  List<Object> get props => [];
}

final class AddFiles extends MediaSenderEvent {
  final List<File> selectedFiles;
  final String? error;

  const AddFiles(this.selectedFiles, {this.error});
}

final class PickCamera extends MediaSenderEvent {
  const PickCamera();
}

final class PickMedia extends MediaSenderEvent {
  const PickMedia();
}

final class ChangeMessage extends MediaSenderEvent {
  final String message;

  const ChangeMessage(this.message);
}

final class RemoveFile extends MediaSenderEvent {
  final File fileToRemove;

  const RemoveFile(this.fileToRemove);
}

final class _CleanError extends MediaSenderEvent {
  const _CleanError();
}

final class SendMessage extends MediaSenderEvent {
  final MessageModel? replyMessage;

  const SendMessage(this.replyMessage);
}

final class CancelSelection extends MediaSenderEvent {
  const CancelSelection();
}
