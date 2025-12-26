part of 'media_sender_bloc.dart';

enum MediaSelectorStatus {
  initial,
  mediaSelected,
  picking,
  processing,
  processingFinished,
  canceled,
  sendingFailed
}

final class MediaSenderState extends Equatable {
  MediaSenderState({
    this.status = MediaSelectorStatus.initial,
    this.selectedFiles = const <File>[],
    this.message = '',
    this.error = '',
  });

  final MediaSelectorStatus status;
  final List<File> selectedFiles;
  final String message;
  final String error;

  final StreamController<UploadingProgress> _progressController =
      StreamController.broadcast();

  StreamController<UploadingProgress> get progressController =>
      _progressController;

  Stream<UploadingProgress> get progressStream => _progressController.stream;

  MediaSenderState copyWith({
    MediaSelectorStatus? status,
    List<File>? selectedFiles,
    String? message,
    String? error,
  }) {
    return MediaSenderState(
      status: status ?? this.status,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'MediaSelectorState { status: $status, selectedFiles: $selectedFiles, message: $message, error: $error}';
  }

  @override
  List<Object> get props => [status, selectedFiles, message, error];
}

typedef UploadingProgress = MapEntry<String, int>;
