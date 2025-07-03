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

  Future<List<List<String>>> getDecisionPairs(String userInput) async {
    final url = Uri.parse(endpoint);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content":
                "Return a JSON array of at least two [option, encouragement] pairs for any decision-style input (including yes/no questions). If the input is not a choice-style question, return an empty array []. Do not include any explanation—just the raw array.",
          },
          {"role": "user", "content": userInput},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded['choices'][0]['message']['content'];

      // List<List<String>>
      final list = jsonDecode(content);
      if (list is List &&
          list.every(
            (item) =>
                item is List &&
                item.length == 2 &&
                item.every((sub) => sub is String),
          )) {
        return List<List<String>>.from(list.map((e) => List<String>.from(e)));
      } else {
        throw Exception('wrong format');
      }
    } else {
      throw Exception('fail to request GPT API: ${response.statusCode}');
    }
  }
}
