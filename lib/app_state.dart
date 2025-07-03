import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/whisper_service.dart';
import 'services/recording_service.dart';

class DecidyState extends ChangeNotifier {
  String spokenText = '';
  String decisionResult = '';
  final RecordingService _recordingService = RecordingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> startRecording() async {
    await _recordingService.startRecording();
  }

  Future<void> stopRecording() async {
    await _recordingService.stopRecording();
    notifyListeners();
  }

  Future<void> playRecording() async {
    final file = await _recordingService.getRecordedFile();
    if (file == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(file.path));
    } catch (e) {
      debugPrint('fail to play the audio: $e');
    }
  }

  Future<void> transcribeRecording() async {
    final file = await _recordingService.getRecordedFile();
    if (file == null) {
      spokenText = 'fail to find the audio file when transcribe';
      notifyListeners();
      return;
    }
    final whisper = WhisperService();
    spokenText = await whisper.transcribe(file);

    notifyListeners();
  }

  @override
  void dispose() {
    _recordingService.dispose();
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
