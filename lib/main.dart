import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/home_page.dart';
import 'app_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
