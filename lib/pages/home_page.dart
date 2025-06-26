import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'result_page.dart';

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
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 400), // 更缓一些
                pageBuilder: (_, __, ___) => ResultPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic, // 更自然的“空气中浮现”感
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.mic, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
