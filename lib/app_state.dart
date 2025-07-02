import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './whisper_service.dart';

class DecidyState extends ChangeNotifier {
  String spokenText = '我要不要吃炸鸡';
  String decisionResult = '当然要！炸鸡不等人！';
  final _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordedFilePath;

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/decidy_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    _recordedFilePath = path;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    notifyListeners();
  }

  Future<void> playRecording() async {
    if (_recordedFilePath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
    } catch (e) {
      debugPrint('fail to play the audio: $e');
    }
  }

  Future<void> transcribeRecording() async {
    if (_recordedFilePath == null) {
      spokenText = 'fail to find the audio file when transcribe';
      notifyListeners();
      return;
    }

    final file = File(_recordedFilePath!);
    final whisper = WhisperService();
    spokenText = await whisper.transcribe(file);

    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  void setSpokenText(String text) {
    spokenText = text;
    notifyListeners();
  }

  void clear() {
    spokenText = '';
    decisionResult = '';
    notifyListeners();
  }
}
