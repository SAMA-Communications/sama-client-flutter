part of 'sharing_intent_bloc.dart';

enum SharingIntentStatus {
  initial,
  sharing,
  processing,
  completed,
}

final class SharingIntentState extends Equatable {
  const SharingIntentState(
      {this.status = SharingIntentStatus.initial,
      this.sharedFiles = const <SharedMediaFile>[]});

  final SharingIntentStatus status;
  final List<SharedMediaFile> sharedFiles;

  SharingIntentState copyWith({
    SharingIntentStatus? status,
    List<SharedMediaFile>? sharedFiles,
  }) {
    return SharingIntentState(
      status: status ?? this.status,
      sharedFiles: sharedFiles ?? this.sharedFiles,
    );
  }

  @override
  List<Object> get props => [status, sharedFiles];
}
