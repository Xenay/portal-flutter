import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  const VideoBackground({Key? key}) : super(key: key);

  @override
  _VideoBackgroundState createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/portalBackground.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {}); // Rebuild once the video is initialized.
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // If the video is initialized, use FittedBox to cover the background.
    return _controller.value.isInitialized 
      ? FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        )
      : Container(color: Colors.black);
  }
}
