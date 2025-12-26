import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../db/models/attachment_model.dart';
import '../../../shared/ui/colors.dart';
import '../../../shared/utils/media_utils.dart';

class MediaAttachmentWidget extends StatefulWidget {
  final List<AttachmentModel> attachments;
  final int index;

  const MediaAttachmentWidget(this.attachments, this.index, {super.key});

  @override
  MediaAttachmentWidgetState createState() => MediaAttachmentWidgetState();
}

class MediaAttachmentWidgetState extends State<MediaAttachmentWidget> {
  final CarouselSliderController controller = CarouselSliderController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentPage = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PhotoViewGestureDetectorScope(
            axis: Axis.horizontal,
            child: CarouselSlider(
              items: widget.attachments.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: _buildAttachmentView(item));
                  },
                );
              }).toList(),
              carouselController: controller,
              options: CarouselOptions(
                  initialPage: widget.index,
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentPage = index;
                    });
                  }),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.attachments.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(
                    vertical: Platform.isIOS ? 20.0 : 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? white
                            : black)
                        .withValues(
                            alpha: currentPage == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttachmentView(AttachmentModel attachment) {
    return isImage(attachment.fileName, attachment.contentType)
        ? PhotoView(imageProvider: CachedNetworkImageProvider(attachment.url!))
        : VideoView(attachment: attachment);
  }
}

class VideoView extends StatefulWidget {
  final AttachmentModel attachment;

  const VideoView({super.key, required this.attachment});

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    var fileInfo =
        await DefaultCacheManager().getFileFromCache(widget.attachment.url!);
    if (fileInfo?.file != null) {
      _videoController = VideoPlayerController.file(fileInfo!.file);
    } else {
      DefaultCacheManager().downloadFile(widget.attachment.url!);
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.attachment.url!));
    }
    _videoController?.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        // fix https://github.com/fluttercommunity/chewie/issues/907
        progressIndicatorDelay:
            Platform.isAndroid ? const Duration(days: 1) : null,
      );
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  FutureBuilder(
                      future: getVideoThumbnailByUrl(
                          widget.attachment.url!, widget.attachment.fileId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return Image.file(
                          File(snapshot.data!),
                          fit: BoxFit.cover,
                          cacheHeight: 400,
                        );
                      }),
                  const CircularProgressIndicator()
                ],
              ));
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
