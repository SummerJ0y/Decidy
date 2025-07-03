import 'dart:math';

class RandomService {
  static final _random = Random();

  static List<String> pickOnePair(List<List<String>> list) {
    if (list.isEmpty) {
      throw ArgumentError('List cannot be empty');
    }
    return list[_random.nextInt(list.length)];
  }
}
