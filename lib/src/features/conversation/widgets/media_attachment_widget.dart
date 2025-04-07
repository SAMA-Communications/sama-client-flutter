import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: false,
        titleSpacing: 0.0,
        title: const Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: Text(
            overflow: TextOverflow.ellipsis,
            'Photo preview',
            style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
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
                enableInfiniteScroll: widget.attachments.length > 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentPage = index;
                  });
                }),
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
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
      ]),
    );
  }

  Widget _buildAttachmentView(AttachmentModel attachment) {
    return isImage(attachment.fileName!)
        ? PhotoView(imageProvider: CachedNetworkImageProvider(attachment.url!))
        : VideoView(url: attachment.url!);
  }
}

class VideoView extends StatefulWidget {
  final String url;

  const VideoView({super.key, required this.url});

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoView> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  // ClosedCaption(text: _controller.value.caption.text),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller,
                      allowScrubbing: true,
                      colors:
                          const VideoProgressColors(playedColor: slateBlue)),
                ],
              ),
            )
          : const CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                reverseDuration: const Duration(milliseconds: 200),
                child: controller.value.isPlaying
                    ? const SizedBox.shrink()
                    : const ColoredBox(
                        color: Colors.black26,
                        child: Center(
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 100.0,
                            semanticLabel: 'Play',
                          ),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: () {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                },
              ),
            ],
          );
        });
  }
}
