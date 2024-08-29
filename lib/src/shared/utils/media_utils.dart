import 'dart:io';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'file_utils.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType?.startsWith('image/') ?? false;
}

bool isVideo(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('video/') ?? false;
}

Future<String?> getMediaBlurHash(File file) async {
  if (isImage(file.path)) {
    return getImageHashAsync(file);
  } else if (isVideo(file.path)) {
    return getVideoHashAsync(file);
  } else {
    // TODO VT add blurhash generation for other types of file
    return null;
  }
}

Future<String> getImageHashAsync(File imageFile) async {
  var imageData = await FlutterImageCompress.compressWithFile(
    imageFile.path,
    minHeight: 480,
    minWidth: 640,
  );

  var image = img.decodeImage(imageData!);
  return BlurHash.encode(image!, numCompX: 4, numCompY: 3).hash;
}

Future<String> getVideoHashAsync(File videoFile) async {
  var imageData = await VideoCompress.getByteThumbnail(videoFile.path,
      quality: 10, position: -1);

  var image = img.decodeImage(imageData!);
  return BlurHash.encode(image!, numCompX: 4, numCompY: 3).hash;
}

Future<double?> getVideoDuration(File videoFile) async {
  return VideoCompress.getMediaInfo(videoFile.path).then((mediaInfo) {
    return mediaInfo.duration;
  });
}

Future<double?> getVideoDurationByUrl(String url) async {
  return 0;
}

Future<File> compressImageFile(File imageFile) async {
  var tempPath =
      '${(await getTemporaryDirectory()).path}/images/attachments/${basename(imageFile.path)}';

  var compressedFile = File(tempPath);
  await compressedFile.create(recursive: true);

  try {
    await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      compressedFile.path,
      minHeight: 720,
      minWidth: 1080,
    );

    return compressedFile;
  } catch (e) {
    return imageFile;
  }
}

Future<File> compressVideoFile(File videoFile) async {
  try {
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.MediumQuality,
      includeAudio: true,
    );

    var result = mediaInfo?.file ?? videoFile;
    if (basename(result.path) != basename(videoFile.path)) {
      result = changeFileNameOnly(result, basename(videoFile.path));
    }

    return result;
  } catch (e) {
    return videoFile;
  }
}

Future<File> getVideoThumbnail(File videoFile) async {
  return VideoCompress.getFileThumbnail(
    videoFile.path,
    quality: 50,
  );
}

Future<String?> getVideoThumbnailByUrl(String url, String fileId) async {
  final Directory cacheDir = await getTemporaryDirectory();

  final String target = File('${cacheDir.path}/video/thumbnails/$fileId').path;
  if (File(target).existsSync()) {
    return target;
  } else {
    File(target).createSync(recursive: true);
  }

  return VideoThumbnail.thumbnailFile(
    video: url,
    thumbnailPath: cacheDir.path,
    imageFormat: ImageFormat.JPEG,
    maxHeight: 640,
    quality: 80,
  ).then((path){
    return File(path!).rename(target).then((file) {
      return file.path;
    });
  });
}

Future<File> compressFile(File file) async {
  if (isImage(file.path)) {
    return compressImageFile(file);
  } else if (isVideo(file.path)) {
    return compressVideoFile(file);
  } else {
    // TODO VT return original file if compressing is not required
    return file;
  }
}

List<QuiltedGridTile> getGridPatternForCount(int count) {
  switch (count) {
    case 1:
      return [
        const QuiltedGridTile(4, 4),
      ];

    case 2:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(3, 2),
      ];
    case 3:
    case 6:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(2, 2),
      ];
    case 4:
    case 8:
      return [
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(2, 2),
      ];

    case 5:
    case 0:
    case 10:
      return [
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 2),
      ];

    case 7:
      return [
        const QuiltedGridTile(2, 2),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 1),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(1, 2),
        const QuiltedGridTile(3, 2),
        const QuiltedGridTile(2, 2),
      ];

    case 9:
      return [...getGridPatternForCount(5), ...getGridPatternForCount(4)];
  }

  // TODO VT develop an algorithm for building a grid for more than 10 items
  return getGridPatternForCount(count ~/ 10);
}

const supportedImageAttachmentExtentions = [
  'heic',
  'jpeg',
  'jpg',
  'png',
  'gif',
  'bmp',
];

const supportedVideoAttachmentExtentions = [
  'mp4',
  'webm',
  'quicktime',
];
