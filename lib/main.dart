import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/home_page.dart';
import './pages/result_page.dart';
import 'app_state.dart'; 

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

