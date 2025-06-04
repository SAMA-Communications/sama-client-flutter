import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../api/api.dart';
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
    return SizedBox(
        height: 200,
        child: FutureBuilder(
            future: linkPreview(),
            builder:
                (BuildContext context, AsyncSnapshot<LinkPreview> snapshot) {
              if (snapshot.hasData &&
                  (snapshot.data?.images?.isNotEmpty ?? false)) {
                var linkPreview = snapshot.data!;
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: double.infinity,
                          height: 100.0,
                          child: CachedNetworkImage(
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          slateBlue),
                                    ))),
                            errorWidget: (context, url, error) {
                              return const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: dullGray,
                                  size: 50.0,
                                ),
                              );
                            },
                            imageUrl: linkPreview.images?.firstOrNull ?? '',
                            fit: BoxFit.cover,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        softWrap: true,
                        textAlign: TextAlign.justify,
                        linkPreview.description ?? '',
                        maxLines: 4,
                        style: const TextStyle(color: dullGray, fontSize: 12.0, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 10),
                    ]);
              } else {
                return const SizedBox.shrink();
              }
            }));
  }
}
