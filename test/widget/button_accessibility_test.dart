import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/widgets/game_widgets.dart';

void main() {
  group('Button Accessibility Tests', () {
    testWidgets('InfoButton meets accessibility size requirements', (WidgetTester tester) async {
      // Test with different sizes including very small values
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                InfoButton(
                  onPressed: () {},
                  size: 20, // Small size that should be auto-corrected
                ),
                InfoButton(
                  onPressed: () {},
                  size: 30, // Medium size below minimum
                ),
                InfoButton(
                  onPressed: () {},
                  size: 48, // Exact minimum size
                ),
                InfoButton(
                  onPressed: () {},
                  size: 60, // Larger than minimum
                ),
              ],
            ),
          ),
        ),
      );

      // Find the buttons
      final infoButtons = tester.widgetList<InfoButton>(find.byType(InfoButton));
      
      // Test each button
      for (final button in infoButtons) {
        // Get the SizedBox parent instead of the Container
        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byWidget(button),
            matching: find.byType(SizedBox),
          ),
        );
        
        // Check dimensions
        expect(sizedBox.width, equals(48.0), reason: "InfoButton width should be exactly 48.0");
        expect(sizedBox.height, equals(48.0), reason: "InfoButton height should be exactly 48.0");
      }
    });
    
    testWidgets('StatsButton meets accessibility size requirements', (WidgetTester tester) async {
      // Test with different sizes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatsButton(
                  onPressed: () {},
                  size: 20, // Small size that should be auto-corrected
                ),
                StatsButton(
                  onPressed: () {},
                  size: 48, // Exact minimum size
                ),
              ],
            ),
          ),
        ),
      );

      // Find the buttons
      final statsButtons = tester.widgetList<StatsButton>(find.byType(StatsButton));
      
      // Test each button
      for (final button in statsButtons) {
        // Get the SizedBox parent instead of the Container
        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byWidget(button),
            matching: find.byType(SizedBox),
          ),
        );
        
        // Check dimensions
        expect(sizedBox.width, equals(48.0), reason: "StatsButton width should be exactly 48.0");
        expect(sizedBox.height, equals(48.0), reason: "StatsButton height should be exactly 48.0");
      }
    });
    
    testWidgets('GameSquare meets accessibility size constraints', (WidgetTester tester) async {
      // Test GameSquare with different configurations
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 30, // Too small
                  height: 30, // Too small
                  child: GameSquare(
                    letter: 'A',
                    selected: false,
                    onTap: () {},
                  ),
                ),
                SizedBox(
                  width: 48, // Exact minimum
                  height: 48, // Exact minimum
                  child: GameSquare(
                    letter: 'B',
                    selected: false,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Test GameSquare constraints
      final gameSquares = tester.widgetList<GameSquare>(find.byType(GameSquare));
      
      // Check if constraints are properly defined
      for (final square in gameSquares) {
        // Find the Container with constraints
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byWidget(square),
            matching: find.byType(Container),
          ),
        );
        
        final constraints = container.constraints;
        expect(constraints, isNotNull, reason: "GameSquare should have constraints");
        
        if (constraints != null) {
          expect(constraints.minWidth, equals(48.0), reason: "GameSquare minWidth should be 48.0");
          expect(constraints.minHeight, equals(48.0), reason: "GameSquare minHeight should be 48.0");
        }
      }
    });
  });
}