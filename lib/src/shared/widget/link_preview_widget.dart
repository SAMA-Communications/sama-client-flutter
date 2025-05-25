import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../api/api.dart';
import '../../features/conversations_list/conversations_list.dart';
import '../ui/colors.dart';

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
    return FutureBuilder(
        future: linkPreview(),
        builder: (BuildContext context, AsyncSnapshot<LinkPreview> snapshot) {
          if (snapshot.hasData) {
            var linkPreview = snapshot.data!;
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    maxHeightDiskCache: 600,
                    maxWidthDiskCache: 600,
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(slateBlue),
                            ))),
                    errorWidget: (context, url, error) => const Center(
                      child: SizedBox.expand(
                          child: Icon(
                        Icons.image_outlined,
                        color: dullGray,
                        size: 50.0,
                      )),
                    ),
                    imageUrl: linkPreview.images?.firstOrNull ?? '',
                    fit: BoxFit.fill,
                  ),
                  Text(
                    linkPreview.title ?? '',
                    // style: linkStyle,
                  ),
                ]);
            // return Image.network(
            //   snapshot.data ?? '',
            //   height: 75.0,
            //   width: 75.0,
            //   fit: BoxFit.cover,
            //   errorBuilder: (BuildContext context, Object exception,
            //       StackTrace? stackTrace) {
            //     return errorBody != null
            //         ? Text(errorBody!)
            //         : const Icon(
            //             Icons.image_outlined,
            //             color: dullGray,
            //             size: 50.0,
            //           );
            //   },
            // );
          }
          return const CenterLoader();
        });
  }
}
