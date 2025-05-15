import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Debug test for xyzwpdqrsting', () {
    test('Print isCommonEnglishWord result for xyzwpdqrsting', () {
      final result = isCommonEnglishWord('xyzwpdqrsting');
      print('isCommonEnglishWord("xyzwpdqrsting") returns: $result');
      
      // Check if it has any common ending
      final List<String> commonEndings = ['ing', 'ed', 's', 'er', 'ly', 'est', 'ment', 'tion', 'ness', 'ful', 'less'];
      for (String ending in commonEndings) {
        if ('xyzwpdqrsting'.toLowerCase().endsWith(ending)) {
          print('Ends with: $ending');
        }
      }
      
      // Check vowel count
      int vowelCount = 0;
      for (int i = 0; i < 'xyzwpdqrsting'.length; i++) {
        if ('AEIOUaeiou'.contains('xyzwpdqrsting'[i])) {
          vowelCount++;
        }
      }
      print('Vowel count: $vowelCount');
      print('Word length: ${'xyzwpdqrsting'.length}');
      print('Vowel ratio check: ${vowelCount >= 'xyzwpdqrsting'.length / 3}');
    });
  });
}
