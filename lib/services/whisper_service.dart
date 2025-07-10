import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A service for transcribing audio files using OpenAI's Whisper API.
///
/// Requires the `OPENAI_API_KEY` to be set in the .env.
/// Uses the `whisper-1` model to convert speech to text.
class WhisperService {
  final Dio _dio = Dio()
    ..options.headers['Authorization'] =
        'Bearer ${dotenv.env['OPENAI_API_KEY']}';

  Future<String> transcribe(File audioFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'audio.m4a',
      ),
      'model': 'whisper-1',
    });

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
      );

      return response.data['text'] ?? 'fail to transcript';
    } catch (e) {
      return 'fail to upload or transcript：$e';
    }
  }
}
