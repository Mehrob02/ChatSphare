import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioPlayer extends StatefulWidget {
  const ChatAudioPlayer({super.key, required this.source});
  final AudioSource source;
  @override
  State<ChatAudioPlayer> createState() => _ChatAudioPlayerState();
}

class _ChatAudioPlayerState extends State<ChatAudioPlayer> {
  final AudioPlayer _audioPlayer=AudioPlayer();
  late StreamSubscription<PlayerState> _playerStateChangedSubscription;
 
   Duration position = Duration.zero;
   Duration? duration = Duration.zero;
  bool isPaused= true;
  @override
  void initState() {
    _playerStateChangedSubscription = _audioPlayer.playerStateStream.listen((PlayerState state) async {
      if (state.processingState == ProcessingState.completed) {
        await stop();
      }
    });
    _init(); 
    super.initState();
  }
  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    setState(() {
      isPaused=true;
    });
    await _audioPlayer.stop();
    return _audioPlayer.seek(Duration.zero);
  }
   Future<void> _init() async {
    await _audioPlayer.setAudioSource(widget.source);
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: (){setState(() {
            isPaused=!isPaused;
          }); isPaused?_audioPlayer.pause():_audioPlayer.play();}, icon: Icon(!isPaused?Icons.pause_rounded :Icons.play_arrow_rounded)),
          Expanded(
            child: Slider(
             onChanged: (double v) {
        },
        value: 0.0,
              ),
          ),
        ],
      ));
  }
}