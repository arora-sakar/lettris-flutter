import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Square class tests', () {
    test('Square initialization', () {
      final square = Square(index: 5);
      expect(square.index, equals(5));
      expect(square.alphabet, equals(''));
      expect(square.selected, equals(-1));
    });

    test('Square initialization with values', () {
      final square = Square(
        index: 10,
        alphabet: 'A',
        selected: 2,
      );
      expect(square.index, equals(10));
      expect(square.alphabet, equals('A'));
      expect(square.selected, equals(2));
    });

    test('Square copyWith method', () {
      final square = Square(index: 5);
      final copiedSquare = square.copyWith(
        alphabet: 'B',
        selected: 3,
      );
      expect(copiedSquare.index, equals(5)); // Same as original
      expect(copiedSquare.alphabet, equals('B')); // Updated
      expect(copiedSquare.selected, equals(3)); // Updated
      
      // Original square should be unchanged
      expect(square.alphabet, equals(''));
      expect(square.selected, equals(-1));
    });
  });

  group('Letter generation tests', () {
    test('getPseudorandomLetter returns a valid letter', () {
      final letter = getPseudorandomLetter();
      expect(letter.length, equals(1));
      expect(letter, matches(RegExp(r'[A-Z]')));
    });

    test('getPseudorandomLetter distribution is weighted', () {
      // Test that common letters appear more frequently than rare ones
      final letters = List.generate(1000, (_) => getPseudorandomLetter());
      
      // Count frequencies
      final frequencies = <String, int>{};
      for (final letter in letters) {
        frequencies[letter] = (frequencies[letter] ?? 0) + 1;
      }
      
      // Common letters like E, A, R should appear more than rare ones like Q, Z
      expect(frequencies['E'] ?? 0, greaterThan(frequencies['Q'] ?? 0));
      expect(frequencies['A'] ?? 0, greaterThan(frequencies['Z'] ?? 0));
      expect(frequencies['R'] ?? 0, greaterThan(frequencies['X'] ?? 0));
    });
  });

  group('Word validation tests', () {
    test('isCommonEnglishWord identifies common patterns', () {
      // Words with common endings
      expect(isCommonEnglishWord('walking'), isTrue);
      expect(isCommonEnglishWord('played'), isTrue);
      expect(isCommonEnglishWord('cats'), isTrue);
      expect(isCommonEnglishWord('faster'), isTrue);
      
      // Words with good vowel/consonant ratio
      expect(isCommonEnglishWord('table'), isTrue);
      
      // Short words should not automatically pass
      expect(isCommonEnglishWord('xyz'), isFalse);
      
      // Words without standard vowels (A, E, I, O, U) should fail
      // In the current implementation, 'Y' is not counted as a vowel
      expect(isCommonEnglishWord('crypt'), isFalse);
      
      // Special case: 'xyzwpdqrsting' ends with 'ing', which is a common ending
      // Since it's longer than 'ing'.length + 2, it would return true
      expect(isCommonEnglishWord('xyzwpdqrsting'), isTrue);
    });
    
    test('checkValidWord validates words correctly', () async {
      SharedPreferences.setMockInitialValues({
        'cat': 'valid',
        'dog': 'valid',
        localWordsVersion: true,
      });
      
      // Words should be at least 3 letters
      expect(await checkValidWord('a'), isFalse);
      expect(await checkValidWord('ab'), isFalse);
      
      // Words in the dictionary should be valid
      expect(await checkValidWord('cat'), isTrue);
      expect(await checkValidWord('dog'), isTrue);
      
      // Unknown words with common endings should be valid
      expect(await checkValidWord('walking'), isTrue);
      expect(await checkValidWord('played'), isTrue);
      
      // Unknown words without common patterns should be checked via API
      // This is harder to test without mocking the http calls
      // We'll assume the API validation works as expected
    });
  });

  group('High score tests', () {
    test('getHighScore retrieves the high score', () async {
      SharedPreferences.setMockInitialValues({
        'highScore': 100,
      });
      
      final highScore = await getHighScore();
      expect(highScore, equals(100));
    });
    
    test('getHighScore returns 0 when no high score exists', () async {
      SharedPreferences.setMockInitialValues({});
      
      final highScore = await getHighScore();
      expect(highScore, equals(0));
    });
    
    test('saveHighScore stores the high score', () async {
      SharedPreferences.setMockInitialValues({});
      
      await saveHighScore(150);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('highScore'), equals(150));
    });
  });
}
