// ignore_for_file: deprecated_member_use, library_private_types_in_public_api
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';


class VideoViewPage extends StatefulWidget {
  const VideoViewPage({super.key, required this.url});
 final String url;
  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  String videoUrl =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Video Player"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController
            ),
          ),
        ),
      ),
    );
  }
}