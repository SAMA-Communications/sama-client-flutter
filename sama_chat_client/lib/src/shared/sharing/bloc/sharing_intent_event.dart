part of 'sharing_intent_bloc.dart';

sealed class SharingIntentEvent extends Equatable {
  const SharingIntentEvent();

  @override
  List<Object> get props => [];
}

final class SharingIntentReceived extends SharingIntentEvent {
  const SharingIntentReceived({required this.sharedFiles});

  final List<SharedMediaFile> sharedFiles;

  @override
  List<Object> get props => [sharedFiles];
}

final class SharingIntentProcessing extends SharingIntentEvent {}

final class SharingIntentCompleted extends SharingIntentEvent {}
