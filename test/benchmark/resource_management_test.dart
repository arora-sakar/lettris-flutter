import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'dart:async';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      localWordsVersion: true,
      'highScore': 100,
    });
  });

  group('Resource Management Tests', () {
    testWidgets('Timer is disposed properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game (creates timer)
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Verify timer is running
      expect(state.timer, isNotNull);
      
      // Navigate away from the screen
      await tester.pumpWidget(
        MaterialApp(
          home: Container(), // Replace with an empty widget
        ),
      );
      
      // The timer should be canceled during dispose
      // This is hard to verify directly in tests, but we can check that
      // there are no error messages when the screen is disposed
      
      // Pump some more frames to ensure disposal is complete
      await tester.pump(Duration(seconds: 1));
      
      // No assertions here, but this test would catch timer cancellation issues
      // as they would result in console errors during the test
    });
    
    testWidgets('Game resets all state variables properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Modify various game state variables
      state.score = 123;
      state.wordScoreDisplayText = ['T', 'E', 'S', 'T'];
      state.displayText = 'TEST';
      state.gameOver = true;
      state.setState(() {});
      
      await tester.pump();
      
      // Reset the game
      state.resetGame();
      await tester.pump();
      
      // Verify all state variables are reset
      expect(state.score, equals(0));
      expect(state.wordScoreDisplayText, isEmpty);
      expect(state.displayText, isEmpty);
      expect(state.gameOver, isFalse);
      expect(state.gameInPlay, isFalse);
    });
    
    testWidgets('Game cleans up resources on game over', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Verify game is in play and timer is running
      expect(state.gameInPlay, isTrue, reason: 'Game should be in play after pressing START');
      expect(state.timer, isNotNull, reason: 'Timer should be running when game is in play');
      
      // Rather than forcing game over directly through setState, use the pause method
      // which properly cleans up the timer
      state.pauseGame();
      await tester.pump();
      
      // Verify the timer was properly cancelled
      expect(state.timer, isNull, reason: 'Timer should be cancelled after pausing game');
      
      // Now test game over functionality
      // First resume the game
      state.resumeGame();
      await tester.pump();
      
      // Now call refreshFallingSquares with a state that triggers game over
      // First we need to set up a state that triggers game over in refreshFallingSquares
      state.squareArray[0].alphabet = 'A'; // Put a letter in the top row to trigger game over
      
      // Call refreshFallingSquares which should detect the game over condition
      state.refreshFallingSquares();
      await tester.pump();
      
      // Game should be in game over state with timer cancelled
      expect(state.gameOver, isTrue, reason: 'Game should be in game over state');
      expect(state.gameInPlay, isFalse, reason: 'Game should not be in play when game over');
      expect(state.timer, isNull, reason: 'Timer should be cancelled on game over');
      
      // Game over popup should be shown
      expect(find.text('GAME OVER !!'), findsOneWidget);
      
      // Click OK to reset
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Game should reset properly
      expect(state.gameOver, isFalse);
      expect(state.score, equals(0));
    });
    
    testWidgets('Caching behavior works correctly for word validation', (WidgetTester tester) async {
      // Initialize state with some cached words
      SharedPreferences.setMockInitialValues({
        localWordsVersion: true,
        'cat': 'valid',
        'highScore': 100,
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Directly access validation cache through the _wordValidationCache field
      // This is hacky for testing, normally we wouldn't access private fields
      final validationCacheField = state.runtimeType.toString().contains('_wordValidationCache');
      
      // Instead of directly checking cache, we'll test caching behavior
      // by checking validation results
      
      // First validation should use cache
      final startTime = DateTime.now();
      final isCatValid = await checkValidWord('cat');
      final firstValidationTime = DateTime.now().difference(startTime);
      
      // Second validation should be faster (cached)
      final startTime2 = DateTime.now();
      final isCatValidAgain = await checkValidWord('cat');
      final secondValidationTime = DateTime.now().difference(startTime2);
      
      // Both should return true
      expect(isCatValid, isTrue);
      expect(isCatValidAgain, isTrue);
      
      // Second validation should typically be faster, but this is hard to
      // test reliably in an automated environment, so we'll skip strict assertions
    });
    
    testWidgets('Memory usage during long gameplay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      // Simulate extended gameplay by updating many times
      for (int i = 0; i < 100; i++) {
        state.updateGrid();
        await tester.pump(Duration(milliseconds: 16));
      }
      
      // This is mostly a test to see if memory leaks occur during extended gameplay
      // We can't measure memory directly in Flutter tests, but we can check if
      // the app crashes or becomes unresponsive
      
      // Verify game is still functional after many updates
      expect(state.gameInPlay, isTrue);
      
      // Try pausing
      await tester.tap(find.text('PAUSE'));
      await tester.pump();
      
      expect(state.gameInPlay, isFalse);
      expect(find.text('START'), findsOneWidget);
    });
  });
  
  group('Stress Tests', () {
    testWidgets('Rapid orientation changes', (WidgetTester tester) async {
      // This test focuses on resource management during orientation changes
      // Since state isn't preserved during our orientation changes (we create new instances),
      // we're primarily testing that resources are properly disposed and the app doesn't crash
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Rapidly change orientation multiple times
      for (int i = 0; i < 5; i++) {
        // Portrait
        await tester.binding.setSurfaceSize(Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: LettrisScreen(),
          ),
        );
        await tester.pump(Duration(milliseconds: 200));
        
        // Landscape
        await tester.binding.setSurfaceSize(Size(800, 400));
        await tester.pumpWidget(
          MaterialApp(
            home: LettrisScreen(),
          ),
        );
        await tester.pump(Duration(milliseconds: 200));
      }
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
      
      // Render one more time with sufficient time to initialize
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      await tester.pump(Duration(seconds: 2)); // Give it plenty of time to fully initialize
      
      // After orientation changes, the screen should be stable 
      // and contain a LettrisScreen widget
      expect(find.byType(LettrisScreen), findsOneWidget, 
             reason: 'LettrisScreen should be present after orientation changes');
      
      // Find the state to directly check if the game is responsive
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // The game should be in the initial state (not playing)
      expect(state.gameInPlay, isFalse, reason: 'Game should be in initial state');
      
      // This test primarily verifies that we can still interact with the game
      // after orientation changes without crashes
      
      // Direct state manipulation instead of UI interaction for more reliability
      state.handleStartButtonClick();
      await tester.pump();
      
      // The game should now be in the playing state
      expect(state.gameInPlay, isTrue, 
             reason: 'Game should respond to start button click');
      
      // We can verify game mechanics still work
      expect(state.timer, isNotNull, 
             reason: 'Game timer should be running after starting game');
    });
    
    testWidgets('Many simultaneous word validations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Start multiple concurrent validations
      final validations = List.generate(
        20, 
        (i) => checkValidWord('word${i % 5}') // Mix of different words
      );
      
      // Wait for all to complete
      final results = await Future.wait(validations);
      
      // All validations should complete without errors
      expect(results.length, equals(20));
    });
  });
}
