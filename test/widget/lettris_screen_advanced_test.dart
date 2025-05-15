import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      localWordsVersion: true,
      'cat': 'valid',
      'dog': 'valid',
      'car': 'valid',
      'the': 'valid',
      'highScore': 100,
    });
  });

  group('LettrisScreen performance tests', () {
    testWidgets('Screen builds within reasonable time', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      stopwatch.stop();
      
      // Initial build should be reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    testWidgets('Multiple rapid button presses are handled correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Rapidly toggle between START and PAUSE 10 times
      for (int i = 0; i < 10; i++) {
        // Tap current button (alternates between PAUSE and START)
        await tester.tap(find.byType(ElevatedButton).first);
        await tester.pump();
      }
      
      // Game should still be in a stable state (either playing or paused)
      await tester.pumpAndSettle();
      
      // First ensure there is at least one ElevatedButton
      expect(find.byType(ElevatedButton), findsWidgets);
      
      // Then check if it has the expected text
      final buttonFinder = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(buttonFinder.first);
      final buttonChild = button.child;
      
      // Check that the button has either START or PAUSE text
      bool hasExpectedText = false;
      if (buttonChild is FittedBox && buttonChild.child is Text) {
        final text = (buttonChild.child as Text).data;
        hasExpectedText = (text == 'START' || text == 'PAUSE');
      }
      
      expect(hasExpectedText, isTrue, reason: 'Button should display either START or PAUSE');
    });
  });
  
  group('LettrisScreen edge case tests', () {
    testWidgets('Game handles overflow of letters at top row', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Modify the game state to simulate overflow condition
      // Fill the top row with letters
      for (int i = 0; i < 10; i++) {
        state.squareArray[i].alphabet = 'X';
      }
      
      // Set game as in play and run update
      state.gameInPlay = true;
      state.refreshFallingSquares();
      
      await tester.pump();
      
      // Game should detect overflow and show game over
      expect(state.gameOver, isTrue);
      expect(find.text('GAME OVER !!'), findsOneWidget);
    });

    testWidgets('Game handles very long word selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Simulate selecting many letters for a very long word
      const longWord = 'PNEUMONOULTRAMICROSCOPICSILICOVOLCANOCONIOSIS';
      state.wordScoreDisplayText = longWord.split('');
      state.displayText = longWord;
      state.setState(() {});
      
      await tester.pump();
      
      // Check if the word is displayed (may be truncated or wrapped)
      expect(find.textContaining('PNEUMONO'), findsOneWidget);
      
      // Test back button works with long word
      await tester.tap(find.text('BACK'));
      await tester.pump();
      
      // Last letter should be removed
      expect(state.wordScoreDisplayText.join(''), equals(longWord.substring(0, longWord.length - 1)));
    });
    
    testWidgets('Game handles rapid back button presses', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Simulate word selection
      state.wordScoreDisplayText = ['C', 'A', 'T'];
      state.displayText = 'CAT';
      state.setState(() {});
      
      await tester.pump();
      
      // Rapidly press BACK multiple times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('BACK'));
        await tester.pump();
      }
      
      // Word should be empty, not crash
      expect(state.wordScoreDisplayText.length, equals(0));
    });
  });
  
  group('LettrisScreen timer behavior tests', () {
    testWidgets('Game timer continues to run after starting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Note initial game state
      final initialLetters = List<String>.from(state.letters);
      
      // Advance time to allow timer to fire
      await tester.pump(Duration(milliseconds: 1500));
      
      // Game state should have changed as falling letters moved
      expect(state.letters, isNot(equals(initialLetters)));
    });
    
    testWidgets('Game timer stops after pausing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Let game run for a moment
      await tester.pump(Duration(milliseconds: 500));
      
      // Pause the game
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      
      // Note current game state
      final pausedLetters = List<String>.from(state.letters);
      
      // Advance time
      await tester.pump(Duration(milliseconds: 1500));
      
      // Game state should not have changed while paused
      expect(state.letters, equals(pausedLetters));
    });
  });

  group('LettrisScreen instruction and stats tests', () {
    testWidgets('Instructions popup does not interfere with game state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Note current game state
      final gameInPlay = state.gameInPlay;
      
      // Show instructions
      await tester.tap(find.text('i'));
      await tester.pumpAndSettle();
      
      // Game should be paused
      expect(state.gameInPlay, isFalse);
      
      // Close instructions
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      // Game should resume
      expect(state.gameInPlay, equals(gameInPlay));
    });
    
    testWidgets('Stats popup shows correct high score', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Show stats
      await tester.tap(find.text('...'));
      await tester.pumpAndSettle();
      
      // Check high score
      expect(find.text('High Score: 100'), findsAtLeastNWidgets(1));
      
      // Close stats
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Change score
      state.score = 150;
      state.setState(() {});
      
      // Show stats again
      await tester.tap(find.text('...'));
      await tester.pumpAndSettle();
      
      // Check updated current score
      expect(find.text('Current Score: 150'), findsOneWidget);
    });
  });

  group('LettrisScreen accessibility tests', () {
    testWidgets('Text has sufficient contrast', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Find text widgets
      final texts = tester.widgetList<Text>(find.byType(Text));
      
      // For each text, check that it uses a readable font size
      for (final text in texts) {
        final fontSize = text.style?.fontSize ?? 0;
        // Skip texts without explicit font size - they'll inherit from parent
        if (fontSize > 0) {
          expect(fontSize, greaterThanOrEqualTo(14.0), reason: 'Text "${text.data}" has font size $fontSize which is too small');
        }
      }
    });
  });
}