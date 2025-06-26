import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

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
