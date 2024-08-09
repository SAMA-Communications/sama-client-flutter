part of 'images_attachment_bloc.dart';

final class ImagesAttachmentState extends Equatable {
  final Map<String, String> urls;

  const ImagesAttachmentState({
    this.urls = const {},
  });

  ImagesAttachmentState copyWith({
    Map<String, String>? urls,
  }) {
    return ImagesAttachmentState(
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
