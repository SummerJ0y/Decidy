import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';

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
      debugPrint('播放失败: $e');
    }
  }

  Future<void> transcribeRecording() async {
    if (_recordedFilePath == null) {
      spokenText = '未找到录音文件';
      notifyListeners();
      return;
    }

    final file = File(_recordedFilePath!);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: 'audio.m4a'),
      'model': 'whisper-1',
      'language': 'zh',
    });

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer <你的OpenAI API Key>';

    try {
      final response = await dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
      );

      spokenText = response.data['text'] ?? '识别失败';
    } catch (e) {
      spokenText = '上传或识别失败：$e';
    }

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
