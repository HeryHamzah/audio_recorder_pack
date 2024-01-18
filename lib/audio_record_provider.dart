import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderProvider extends ChangeNotifier {
  final recorder = FlutterSoundRecorder();
  bool isRecordReady = false;
  File? audioFile;

  bool isPlaying = false;
  final audioPlayer = AudioPlayer();
  // Duration fullDuration = const Duration();
  // Duration position = const Duration();

  void initAudio(File? file) {
    audioFile = file;
    audioPlayer.setLoopMode(LoopMode.off);

    audioPlayer.positionStream.listen((event) async {
      if (event.inSeconds == audioPlayer.duration?.inSeconds) {
        audioPlayer.stop();
        await audioPlayer.seek(Duration.zero);
      }
    });

    notifyListeners();
  }

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw ("error");
    }

    await recorder.openRecorder();
    isRecordReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    notifyListeners();
  }

  // void playingStream() {
  //   audioPlayer.playingStream.listen((event) {
  //     isPlaying = event;

  //     notifyListeners();
  //   });
  // }

  Future<void> changeAudioFile(File file) async {
    audioFile = file;

    if (audioFile != null) {
      await audioPlayer.setFilePath(audioFile!.path);
    }

    notifyListeners();
  }

  void resetAudioFile() {
    audioFile = null;

    notifyListeners();
  }

  Future<void> playAudio() async {
    await audioPlayer.play();

    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();

    notifyListeners();
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();

    notifyListeners();
  }

  Future<void> stopRecorder() async {
    var path = await recorder.stopRecorder();

    if (path != null) {
      audioFile = File(path);
    }

    if (audioFile != null) {
      await audioPlayer.setFilePath(audioFile!.path);
    }

    notifyListeners();
  }

  Future<void> pauseRecorder() async {
    await recorder.pauseRecorder();

    notifyListeners();
  }

  Future<void> resumeRecorder() async {
    await recorder.resumeRecorder();

    notifyListeners();
  }

  Future<void> startRecorder() async {
    await recorder.startRecorder(toFile: 'audio');

    notifyListeners();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }
}
