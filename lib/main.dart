// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(DecidyApp());
}

class DecidyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DecidyState(),
      child: MaterialApp(
        title: 'Decidy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: HomePage(),
      ),
    );
  }
}

class DecidyState extends ChangeNotifier {
  String spokenText = '我要不要吃炸鸡';
  String decisionResult = '当然要！炸鸡不等人！';

  void clear() {
    spokenText = '';
    decisionResult = '';
    notifyListeners();
  }
}

// lib/home_page.dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<DecidyState>();

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) {
            // TODO: Start speech recognition
            print('🎤 开始录音');
          },
          onLongPressEnd: (_) {
            // TODO: Stop speech and navigate
            print('🛑 停止录音，准备跳转');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ResultPage()),
            );
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.mic, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}

// lib/result_page.dart
class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<DecidyState>();

    return Scaffold(
      appBar: AppBar(title: Text('Decidy 回答')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('你刚刚说的是：', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              appState.spokenText,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            Text('Decidy 说：', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(appState.decisionResult, style: TextStyle(fontSize: 22)),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  appState.clear();
                  Navigator.pop(context);
                },
                child: Text('再来一个'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
