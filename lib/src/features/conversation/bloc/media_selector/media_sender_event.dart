part of 'media_sender_bloc.dart';

class MediaSenderEvent extends Equatable {
  const MediaSenderEvent();

  @override
  List<Object> get props => [];
}

final class _AddFiles extends MediaSenderEvent {
  final List<File> selectedFiles;

  const _AddFiles(this.selectedFiles);
}

final class PickMoreFiles extends MediaSenderEvent {
  const PickMoreFiles();
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
  const SendMessage();
}

final class CancelSelection extends MediaSenderEvent {
  const CancelSelection();
}
