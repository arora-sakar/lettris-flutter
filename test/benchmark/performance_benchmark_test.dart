import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'dart:async';

// A utility class for performance testing
class PerformanceTracker {
  final Stopwatch stopwatch = Stopwatch();
  List<int> measurements = [];
  
  void start() {
    stopwatch.reset();
    stopwatch.start();
  }
  
  void stop() {
    stopwatch.stop();
    measurements.add(stopwatch.elapsedMicroseconds);
  }
  
  double get averageMicroseconds => 
      measurements.isEmpty ? 0 : measurements.reduce((a, b) => a + b) / measurements.length;
      
  int get maxMicroseconds =>
      measurements.isEmpty ? 0 : measurements.reduce((a, b) => a > b ? a : b);
      
  int get minMicroseconds =>
      measurements.isEmpty ? 0 : measurements.reduce((a, b) => a < b ? a : b);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      localWordsVersion: true,
      'cat': 'valid',
      'car': 'valid',
      'dog': 'valid',
      'the': 'valid',
      'test': 'valid',
      'word': 'valid',
      'highScore': 100,
    });
  });

  group('Performance Benchmarks', () {
    testWidgets('Initial screen build performance', (WidgetTester tester) async {
      final tracker = PerformanceTracker();
      
      // Run multiple trials
      for (int i = 0; i < 10; i++) {
        // Clean up previous test
        await tester.pumpWidget(Container());
        
        // Start timing
        tracker.start();
        
        // Build the widget
        await tester.pumpWidget(
          MaterialApp(
            home: LettrisScreen(),
          ),
        );
        
        // Initial frame
        await tester.pump();
        
        // Stop timing
        tracker.stop();
      }
      
      // Report results - these are not strict assertions, just information
      print('Initial build performance:');
      print('Average: ${tracker.averageMicroseconds / 1000} ms');
      print('Min: ${tracker.minMicroseconds / 1000} ms');
      print('Max: ${tracker.maxMicroseconds / 1000} ms');
      
      // Set a very conservative upper bound - this is just to catch major regressions
      expect(tracker.averageMicroseconds, lessThan(500000)); // 500ms
    });
    
    testWidgets('Word validation performance', (WidgetTester tester) async {
      final tracker = PerformanceTracker();
      
      // List of words to test
      final testWords = ['cat', 'dog', 'car', 'the', 'test', 'word', 'unknown', 'xyz'];
      
      // Run multiple trials for each word
      for (final word in testWords) {
        tracker.start();
        final isValid = await checkValidWord(word);
        tracker.stop();
      }
      
      // Report results
      print('Word validation performance (${testWords.length} words):');
      print('Average: ${tracker.averageMicroseconds / 1000} ms per word');
      print('Min: ${tracker.minMicroseconds / 1000} ms');
      print('Max: ${tracker.maxMicroseconds / 1000} ms');
      
      // Conservative upper bound - validation should be fast
      expect(tracker.averageMicroseconds, lessThan(100000)); // 100ms average
    });
    
    testWidgets('Game rendering performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      final tracker = PerformanceTracker();
      
      // Measure frame rendering times for multiple frames
      for (int i = 0; i < 20; i++) {
        tracker.start();
        await tester.pump(Duration(milliseconds: 16)); // Roughly 60fps
        tracker.stop();
      }
      
      // Report results
      print('Game rendering performance (20 frames):');
      print('Average: ${tracker.averageMicroseconds / 1000} ms per frame');
      print('Min: ${tracker.minMicroseconds / 1000} ms');
      print('Max: ${tracker.maxMicroseconds / 1000} ms');
      
      // For smooth gameplay, frames should render in under 16ms (60fps)
      // But we'll use a conservative upper bound for CI environments
      expect(tracker.averageMicroseconds, lessThan(50000)); // 50ms average
    });
    
    testWidgets('Letter generation performance', (WidgetTester tester) async {
      final tracker = PerformanceTracker();
      
      // Measure the performance of generating many letters
      for (int i = 0; i < 1000; i++) {
        tracker.start();
        getPseudorandomLetter();
        tracker.stop();
      }
      
      // Report results
      print('Letter generation performance (1000 letters):');
      print('Average: ${tracker.averageMicroseconds} µs per letter');
      
      // Letter generation should be very fast
      expect(tracker.averageMicroseconds, lessThan(100)); // 0.1ms average
    });
    
    testWidgets('Game state update performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      final tracker = PerformanceTracker();
      
      // Measure the performance of game state updates (falling letters)
      for (int i = 0; i < 10; i++) {
        tracker.start();
        state.updateGrid();
        tracker.stop();
      }
      
      // Report results
      print('Game state update performance (10 updates):');
      print('Average: ${tracker.averageMicroseconds / 1000} ms per update');
      
      // Game state updates should be reasonably fast
      expect(tracker.averageMicroseconds, lessThan(50000)); // 50ms average
    });
    
    testWidgets('Word selection and submission performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      // Wait for initialization
      await tester.pump(Duration(seconds: 1));
      
      // Find the LettrisScreenState to access internal game state
      final state = tester.state<LettrisScreenState>(find.byType(LettrisScreen));
      
      // Start the game
      await tester.tap(find.text('START'));
      await tester.pump();
      
      final selectionTracker = PerformanceTracker();
      final submissionTracker = PerformanceTracker();
      
      // Test with a few words
      final words = ['CAT', 'DOG', 'THE', 'CAR'];
      
      for (final word in words) {
        // Setup game state for the word
        state.wordScoreDisplayText = [];
        state.displayText = '';
        state.setState(() {});
        await tester.pump();
        
        // Measure letter selection performance
        for (int i = 0; i < word.length; i++) {
          selectionTracker.start();
          
          // Directly create squares and select them
          final squareIndex = 100 + i; // Just some valid index 
          state.squareArray[squareIndex].alphabet = word[i];
          state.handleSquareClick(squareIndex);
          
          await tester.pump();
          selectionTracker.stop();
        }
        
        // Set word as valid
        state.displayClickable = true;
        state.setState(() {});
        await tester.pump();
        
        // Measure word submission performance
        submissionTracker.start();
        state.handleDisplayClick();
        await tester.pump();
        submissionTracker.stop();
      }
      
      // Report results
      print('Letter selection performance (${words.join('').length} letters):');
      print('Average: ${selectionTracker.averageMicroseconds / 1000} ms per letter');
      
      print('Word submission performance (${words.length} words):');
      print('Average: ${submissionTracker.averageMicroseconds / 1000} ms per word');
      
      // Performance expectations
      expect(selectionTracker.averageMicroseconds, lessThan(50000)); // 50ms average
      expect(submissionTracker.averageMicroseconds, lessThan(100000)); // 100ms average
    });
  });
}
