import 'package:flutter/foundation.dart';

class DecidyState extends ChangeNotifier {
  String spokenText = '我要不要吃炸鸡';
  String decisionResult = '当然要！炸鸡不等人！';

  void clear() {
    spokenText = '';
    decisionResult = '';
    notifyListeners();
  }
}
