part of 'media_attachment_bloc.dart';

final class MediaAttachmentState extends Equatable {
  final Map<String, String> urls;

  const MediaAttachmentState({
    this.urls = const {},
  });

  MediaAttachmentState copyWith({
    Map<String, String>? urls,
  }) {
    return MediaAttachmentState(
      urls: urls ?? this.urls,
    );
  }

  @override
  String toString() {
    return '''PostState { urls: $urls }''';
  }

  @override
  List<Object> get props => [urls];
}
