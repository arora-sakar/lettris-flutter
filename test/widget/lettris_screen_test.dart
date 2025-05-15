import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Set up shared preferences mock
    SharedPreferences.setMockInitialValues({
      localWordsVersion: true,
      'cat': 'valid',
      'dog': 'valid',
      'the': 'valid',
      'car': 'valid',
      'highScore': 100,
    });
  });

  testWidgets('LettrisScreen initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Check for basic UI elements
    expect(find.text('Lettris'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('BACK'), findsOneWidget);
  });

  testWidgets('LettrisScreen shows instructions popup when info button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Find and tap the info button (it has an 'i' text)
    await tester.tap(find.text('i'));
    await tester.pumpAndSettle();

    // Verify instructions popup is shown
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Close the popup
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify popup is closed
    expect(find.text('HOW TO PLAY'), findsNothing);
  });

  testWidgets('LettrisScreen shows stats popup when stats button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Find and tap the stats button (it has '...' text)
    await tester.tap(find.text('...'));
    await tester.pumpAndSettle();

    // Verify stats popup is shown
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('High Score: 100'), findsAtLeastNWidgets(1));
    expect(find.text('Close'), findsOneWidget);

    // Close the popup
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify popup is closed
    expect(find.text('Statistics'), findsNothing);
  });

  testWidgets('LettrisScreen starts game when START button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Find and tap the START button
    await tester.tap(find.text('START'));
    await tester.pump();

    // Verify game is in play (button text changes to PAUSE)
    expect(find.text('PAUSE'), findsOneWidget);
  });

  testWidgets('LettrisScreen pauses game when PAUSE button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Start the game
    await tester.tap(find.text('START'));
    await tester.pump();
    expect(find.text('PAUSE'), findsOneWidget);

    // Pause the game
    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('LettrisScreen displays score', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Open stats to check score
    await tester.tap(find.text('...'));
    await tester.pumpAndSettle();

    // Verify initial score is 0
    expect(find.text('Current Score: 0'), findsOneWidget);
  });

  // Testing game mechanics is challenging but we can verify basic interactions
  testWidgets('BACK button is functional during gameplay', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    // Start the game
    await tester.tap(find.text('START'));
    await tester.pump();

    // The BACK button should be clickable but not have visible effect
    // in the initial state (no letters selected)
    await tester.tap(find.text('BACK'));
    await tester.pump();

    // Game should still be in play
    expect(find.text('PAUSE'), findsOneWidget);
  });

  // Testing orientation changes
  testWidgets('LettrisScreen handles orientation changes', (WidgetTester tester) async {
    // Test portrait orientation
    await tester.binding.setSurfaceSize(Size(400, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Lettris'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // Test landscape orientation
    await tester.binding.setSurfaceSize(Size(800, 400));
    await tester.pumpWidget(
      MaterialApp(
        home: LettrisScreen(),
      ),
    );

    // Wait for initialization
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Lettris'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });
}
