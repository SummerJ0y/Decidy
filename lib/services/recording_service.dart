import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordedFilePath;

  Future<bool> hasPermission() async => await _recorder.hasPermission();

  Future<String?> startRecording() async {
    if (!await hasPermission()) return null;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/decidy_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    _recordedFilePath = path;
    return path;
  }

  Future<void> stopRecording() async => await _recorder.stop();

  Future<File?> getRecordedFile() async {
    if (_recordedFilePath == null) return null;
    return File(_recordedFilePath!);
  }

  void dispose() => _recorder.dispose();
}