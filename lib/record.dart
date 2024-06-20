// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:chatsphere/audio_player.dart';
import 'package:chatsphere/vriables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:just_audio/just_audio.dart' as ap;

import 'model/message.dart';
import 'notification_body.dart';
import 'services/chat/chat_service.dart';



class AudioRecorder extends StatefulWidget {
  const AudioRecorder({required this.onStop, Key? key}) : super(key: key);

  final void Function(String path) onStop;

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<void Function(String path)>.has('onStop', onStop));
  }
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final FlutterSoundRecord _audioRecorder = FlutterSoundRecord();
  Amplitude? _amplitude;

  @override
  void initState() {
    _isRecording = false;
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRecordStopControl(),
                const SizedBox(width: 20),
                _buildPauseResumeControl(),
                const SizedBox(width: 20),
                _buildText(),
              ],
            ),
            if (_amplitude != null) ...<Widget>[
              const SizedBox(height: 40),
              Text('Current: ${_amplitude?.current ?? 0.0}'),
              Text('Max: ${_amplitude?.max ?? 0.0}'),
            ],
          ],
        ),
        
      );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording || _isPaused) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isRecording ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (!_isRecording && !_isPaused) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (!_isPaused) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            _isPaused ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording || _isPaused) {
      return _buildTimer();
    }

    return const Text('Waiting to record');
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final String? path = await _audioRecorder.stop();

    widget.onStop(path!);

    setState(() => _isRecording = false);
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _audioRecorder.getAmplitude();
      setState(() {});
    });
  }
}
class RecordApp extends StatefulWidget {
  const RecordApp({super.key, required this.reciverUserID, this.replyingToMessage, this.replyToId});
  final String reciverUserID;
  final String? replyingToMessage;
  final String? replyToId;
  @override
  _RecordAppState createState() => _RecordAppState();
}

class _RecordAppState extends State<RecordApp> {
  bool showPlayer = false;
  ap.AudioSource? audioSource;
  String? recordedFilePath;
  bool isLoading = false;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final ChatService chatService =ChatService();
  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child:isLoading
            ? CircularProgressIndicator() // Показываем индикатор загрузки
            : showPlayer
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AudioPlayer(
                    source: audioSource!,
                    onDelete: () {
                      setState(() { showPlayer = false; audioSource=null; recordedFilePath=null;});
                    },
                  ),
                )
              : AudioRecorder(
                  onStop: (String path) {
                    setState(() {
                      audioSource = ap.AudioSource.uri(Uri.parse(path));
                      showPlayer = true;
                      recordedFilePath = path;
                    });
                  },
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (audioSource != null)
            ElevatedButton(
              onPressed: _uploadToStorage,
              child: Text("Send to the storage"),
            ),
            ElevatedButton(onPressed: (){ Navigator.pop(context);}, child: Text("Colse")),
          ],
        ),
      );
  }
Future<void> _uploadToStorage() async {
    if (recordedFilePath == null) debugPrint("Error uploading file");
setState(() {
      isLoading = true; // Начало загрузки
    });
    try {
      File file = File(recordedFilePath!);
      String fileName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('audio/$fileName.mp3');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await chatService.sendMessage(widget.reciverUserID, downloadURL,widget.replyingToMessage, MessageType.audio,widget.replyToId);
      try {
        final tokenDoc = await firebaseFirestore.collection("users_tokens").doc(widget.reciverUserID).get();
    final token = tokenDoc.data()?['token'];
      chatService.sendNotification(
       serverKey ,
         "Sent audio",
          token);
     } catch (e) {
       debugPrint("notification didn't sent");
     }
      debugPrint("File uploaded successfully. Download URL: $downloadURL");
      InAppNotification.show(
                 child: NotificationBody(child: Text("File uploaded successfully. Download URL: $downloadURL")),
                 context: context,
                onTap: () => (){},
                 );
    } catch (e) {
      debugPrint("Error uploading file: $e");InAppNotification.show(
                 child: NotificationBody(child: Text("Error uploading file: $e, it may be because you're running in web")),
                 context: context,
                onTap: () => (){},
                 ); 
                setState(() {
        isLoading = false; // Конец загрузки в случае ошибки
      });
    } 
    Navigator.pop(context);
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showPlayer', showPlayer));
    properties.add(DiagnosticsProperty<ap.AudioSource?>('audioSource', audioSource));
  }
}