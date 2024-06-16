import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.videoUrl});
 final String videoUrl;
  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        launchUrl(Uri.parse(widget.videoUrl));
      },
      child: Icon(Icons.video_collection_rounded, size: IconTheme.of(context).size!*2,));
  }
}