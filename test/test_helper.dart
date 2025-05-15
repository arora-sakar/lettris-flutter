import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for setting up test environments
class TestHelper {
  /// Initialize shared preferences with common test values
  static Future<void> setupSharedPreferences() async {
    SharedPreferences.setMockInitialValues({
      localWordsVersion: true,
      'cat': 'valid',
      'dog': 'valid',
      'car': 'valid',
      'the': 'valid',
      'test': 'valid',
      'word': 'valid',
      'highScore': 100,
    });
  }
  
  /// Create a widget test environment for a given widget
  static Widget testableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }
  
  /// Setup a predefined game state for testing
  static void setupGameState(LettrisScreenState state, {
    bool gameInPlay = true,
    bool gameOver = false,
    int score = 0,
    List<String> wordScoreDisplayText = const [],
    String displayText = '',
    bool displayClickable = false,
  }) {
    state.gameInPlay = gameInPlay;
    state.gameOver = gameOver;
    state.score = score;
    state.wordScoreDisplayText = List.from(wordScoreDisplayText);
    state.displayText = displayText;
    state.displayClickable = displayClickable;
  }
  
  /// Setup squares in the game grid for testing
  static void setupGameGrid(LettrisScreenState state, List<SquareData> squareData) {
    for (final data in squareData) {
      if (data.index >= 0 && data.index < state.squareArray.length) {
        state.squareArray[data.index].alphabet = data.letter;
        state.squareArray[data.index].selected = data.selected;
      }
    }
  }
  
  /// Helper for finding widgets with specific properties
  static Finder findWidgetWithText(Type widgetType, String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(widgetType),
    );
  }
  
  /// Get text size from a widget
  static double getTextSize(WidgetTester tester, String text) {
    final textWidget = tester.widget<Text>(find.text(text));
    return textWidget.style?.fontSize ?? 0.0;
  }
}

/// Data class for setting up squares in the game grid
class SquareData {
  final int index;
  final String letter;
  final int selected;
  
  SquareData({
    required this.index,
    required this.letter,
    this.selected = -1,
  });
}

/// Extensions for common test operations
extension WidgetTesterExtensions on WidgetTester {
  /// Wait for animations to complete
  Future<void> waitForAnimations() async {
    await pump();
    await pump(Duration(milliseconds: 500));
  }
  
  /// Set portrait orientation for testing
  Future<void> setPortraitOrientation() async {
    await binding.setSurfaceSize(Size(400, 800));
  }
  
  /// Set landscape orientation for testing
  Future<void> setLandscapeOrientation() async {
    await binding.setSurfaceSize(Size(800, 400));
  }
  
  /// Reset orientation after testing
  Future<void> resetOrientation() async {
    await binding.setSurfaceSize(null);
  }
}

/// A mock implementation of letter generation for testing
String testGetPseudorandomLetter() {
  const letters = ['A', 'B', 'C', 'D', 'E', 'T', 'R', 'S', 'N', 'P'];
  static int index = 0;
  return letters[index++ % letters.length];
}

/// A mock implementation of word validation for testing
Future<bool> testCheckValidWord(String word) async {
  final validWords = ['cat', 'dog', 'car', 'the', 'test', 'word', 'abc', 'abt', 'ace'];
  return validWords.contains(word.toLowerCase());
}
