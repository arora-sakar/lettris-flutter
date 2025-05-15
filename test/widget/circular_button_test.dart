import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/widgets/game_widgets.dart';

void main() {
  group('Circular Button Accessibility Tests', () {
    testWidgets('InfoButton has minimum accessible touch area', (WidgetTester tester) async {
      // Test with a small visual size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: InfoButton(
                onPressed: () {},
                size: 30, // Small visual size
              ),
            ),
          ),
        ),
      );
      
      // The outer SizedBox should be 48x48
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(InfoButton),
          matching: find.byType(SizedBox),
        ),
      );
      
      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
      
      // The GestureDetector should have opaque hit testing
      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(InfoButton),
          matching: find.byType(GestureDetector),
        ),
      );
      
      expect(gesture.behavior, equals(HitTestBehavior.opaque));
      
      // Verify we can tap it
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: InfoButton(
                onPressed: () {
                  tapped = true;
                },
                size: 30,
              ),
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(InfoButton));
      expect(tapped, isTrue);
    });
    
    testWidgets('StatsButton has minimum accessible touch area', (WidgetTester tester) async {
      // Test with a small visual size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatsButton(
                onPressed: () {},
                size: 30, // Small visual size
              ),
            ),
          ),
        ),
      );
      
      // The outer SizedBox should be 48x48
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(StatsButton),
          matching: find.byType(SizedBox),
        ),
      );
      
      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
      
      // The GestureDetector should have opaque hit testing
      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(StatsButton),
          matching: find.byType(GestureDetector),
        ),
      );
      
      expect(gesture.behavior, equals(HitTestBehavior.opaque));
      
      // Verify we can tap it
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatsButton(
                onPressed: () {
                  tapped = true;
                },
                size: 30,
              ),
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(StatsButton));
      expect(tapped, isTrue);
    });
  });
}