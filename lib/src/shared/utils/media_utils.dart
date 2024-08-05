import 'dart:io';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('image/') ?? false;
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
