// lib/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String endpoint;
  final String apiKey;

  AIService({required this.endpoint, required this.apiKey});

  Future<String> getDecision(String userInput) async {
    final url = Uri.parse(endpoint);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o", // or "gpt-4o-mini"
        "messages": [
          {"role": "system", "content": "你是一个果断、风趣的决策助手。"},
          {"role": "user", "content": userInput},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['choices'][0]['message']['content']?.trim() ??
          'I don\'t know how to answer 😅';
    } else {
      throw Exception('fail to request GPT API: ${response.statusCode}');
    }
  }
}
