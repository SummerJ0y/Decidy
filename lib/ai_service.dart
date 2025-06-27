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
        "model": "gpt-4o", // or "gpt-4o-mini" if that's the correct model name
        "messages": [
          {"role": "system", "content": "你是一个果断、风趣的决策助手。"},
          {"role": "user", "content": userInput}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['choices'][0]['message']['content']?.trim() ?? '我不知道该怎么回答 😅';
    } else {
      throw Exception('请求 GPT 接口失败: ${response.statusCode}');
    }
  }
}
