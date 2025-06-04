import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class LinkPreview extends Equatable {
  final String? url; //url
  final String? title; //title
  final String? siteName; //siteName
  final String? description; //description
  final String? mediaType; //mediaType
  final String? contentType; //contentType
  final List<String>? images; //images
  final List<String>? videos; //videos

  const LinkPreview({
    this.url,
    this.title,
    this.siteName,
    this.description,
    this.mediaType,
    this.contentType,
    this.images,
    this.videos,
  });

  LinkPreview.fromJson(Map<String, dynamic>? json)
      : url = json?['url'],
        title = json?['title'],
        siteName = json?['site_name'],
        description = json?['description'],
        mediaType = json?['mediaType'],
        contentType = json?['contentType'],
        images = List.of(json?['images']).cast<String>(),
        videos = List.of(json?['videos'] ?? []).cast<String>();

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'site_name': siteName,
        'description': description,
        'mediaType': mediaType,
        'contentType': contentType,
        'images': images,
        'videos': videos,
      };

  factory LinkPreview.fromUint8List(Uint8List list) {
    return LinkPreview.fromJson(jsonDecode(utf8.decode(list)));
  }

  Uint8List toUint8List() => utf8.encode(jsonEncode(toJson()));

  @override
  List<Object?> get props => [
        url,
        title,
        siteName,
        description,
        mediaType,
        contentType,
        images,
        videos
      ];

  LinkPreview copyWith({
    String? url,
    String? title,
    String? siteName,
    String? description,
    String? mediaType,
    String? contentType,
    List<String>? images,
    List<String>? videos,
  }) {
    return LinkPreview(
      url: url ?? this.url,
      title: title ?? this.title,
      siteName: siteName ?? this.siteName,
      description: description ?? this.description,
      mediaType: mediaType ?? this.mediaType,
      contentType: contentType ?? this.contentType,
      images: images ?? this.images,
      videos: videos ?? this.videos,
    );
  }

  static const empty = LinkPreview();
}
