import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../api/api.dart';
import '../ui/colors.dart';
import '../utils/file_utils.dart';

class LinkPreviewWidget extends StatelessWidget {
  final String link;
  final String? errorBody;

  const LinkPreviewWidget({super.key, required this.link, this.errorBody});

  Future<LinkPreview> linkPreview() async {
    var fileInfo = await DefaultCacheManager().getFileFromCache(link);
    if (fileInfo?.file != null) {
      var linkPreview =
          LinkPreview.fromUint8List(fileInfo!.file.readAsBytesSync());
      return linkPreview;
    } else {
      var linkPreview = await linkPreviewData(link);
      DefaultCacheManager().putFile(link, linkPreview.toUint8List(), key: link);
      return linkPreview;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: FutureBuilder(
            future: linkPreview(),
            builder:
                (BuildContext context, AsyncSnapshot<LinkPreview> snapshot) {
              if (snapshot.hasData) {
                return Card(
                  color: lightMallow,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 4, top: 4, right: 4),
                            child: Text(
                              softWrap: true,
                              textAlign: TextAlign.justify,
                              snapshot.data!.title ?? '',
                              maxLines: 1,
                              style: const TextStyle(
                                  color: dullGray,
                                  fontSize: 15.0,
                                  overflow: TextOverflow.ellipsis),
                            )),
                        SizedBox(
                            width: double.infinity,
                            height: 120.0,
                            child: getPreviewWidget(snapshot.data!)),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 4, bottom: 4, right: 4),
                            child: Text(
                              softWrap: true,
                              textAlign: TextAlign.justify,
                              snapshot.data!.description ?? '',
                              maxLines: 2,
                              style: const TextStyle(
                                  color: dullGray,
                                  fontSize: 12.0,
                                  overflow: TextOverflow.ellipsis),
                            )),
                      ]),
                );
              } else {
                return const SizedBox.shrink();
              }
            }));
  }

  Widget getPreviewWidget(LinkPreview data) {
    if (data.images?.firstOrNull != null) {
      return Image.network(
        data.images!.first,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : const Center(
                    child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(slateBlue),
                        ))),
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          print('Image.network exception= $exception');
          return const Center(
            child: Icon(
              Icons.image_outlined,
              color: dullGray,
              size: 60.0,
            ),
          );
        },
      );
    } else if (data.contentType != null) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        data.favicons?.firstOrNull != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.network(data.favicons!.first,
                    fit: BoxFit.fill, height: 50))
            : const Icon(
                Icons.description_outlined,
                color: dullGray,
                size: 60.0,
              ),
        if (data.fileSize != null)
          Text(
            formatBytes(data.fileSize!),
            style: const TextStyle(color: dullGray, fontSize: 13.0),
          ),
      ]));
    } else {
      return const SizedBox.shrink();
    }
  }
}
