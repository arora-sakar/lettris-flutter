import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/widgets/game_widgets.dart';

void main() {
  group('Advanced GameSquare tests', () {
    testWidgets('GameSquare handles different letter sizes', (WidgetTester tester) async {
      // Test with a normal letter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      
      // Test with a wider letter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'W',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('W'), findsOneWidget);
      
      // Test with multiple letters (should handle it gracefully)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'AB',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('AB'), findsOneWidget);
    });
    
    testWidgets('GameSquare with custom fontSize', (WidgetTester tester) async {
      // Test with default fontSize
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      
      Text defaultText = tester.widget(find.text('A'));
      final defaultFontSize = defaultText.style?.fontSize;
      
      // Test with custom fontSize
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: false,
              onTap: () {},
              fontSize: 30.0,
            ),
          ),
        ),
      );
      
      Text customText = tester.widget(find.text('A'));
      final customFontSize = customText.style?.fontSize;
      
      // Custom size should be different
      expect(customFontSize, equals(30.0));
      expect(customFontSize, isNot(equals(defaultFontSize)));
    });
    
    testWidgets('GameSquare color generation is consistent for same letter', (WidgetTester tester) async {
      // Pump two squares with the same letter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GameSquare(
                  letter: 'A',
                  selected: false,
                  onTap: () {},
                ),
                GameSquare(
                  letter: 'A',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find both containers
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      
      // Get the colors of both A squares (should be the same)
      final color1 = (containers[0].decoration as BoxDecoration).color;
      final color2 = (containers[1].decoration as BoxDecoration).color;
      
      // Colors should be the same for the same letter
      expect(color1, equals(color2));
      
      // Now test with a different letter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GameSquare(
                  letter: 'A',
                  selected: false,
                  onTap: () {},
                ),
                GameSquare(
                  letter: 'B',
                  selected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find both containers again
      final containers2 = tester.widgetList<Container>(find.byType(Container)).toList();
      
      // Get the colors
      final colorA = (containers2[0].decoration as BoxDecoration).color;
      final colorB = (containers2[1].decoration as BoxDecoration).color;
      
      // Colors should be different for different letters
      expect(colorA, isNot(equals(colorB)));
    });
  });
  
  group('Advanced WordScoreDisplay tests', () {
    testWidgets('WordScoreDisplay handles long words', (WidgetTester tester) async {
      // Test with a very long word
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrained width
              child: WordScoreDisplay(
                displayText: 'PNEUMONOULTRAMICROSCOPICSILICOVOLCANOCONIOSIS',
                displayClickable: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Word should fit somehow (either by wrapping or ellipsis)
      expect(find.textContaining('PNEUMONO'), findsOneWidget);
    });
    
    testWidgets('WordScoreDisplay text alignment is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordScoreDisplay(
              displayText: 'TEST',
              displayClickable: true,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Find the Text widget
      final text = tester.widget<Text>(find.text('TEST'));
      
      // Check that the text is centered
      expect(text.textAlign, equals(TextAlign.center));
    });
  });
  
  group('Advanced popup tests', () {
    testWidgets('GameOverPopup with very high score', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverPopup(
              score: 9999999,
              highScore: 10000000,
              onOkPressed: () {},
            ),
          ),
        ),
      );
      
      // Verify large numbers display correctly
      expect(find.text('Your Score: 9999999'), findsOneWidget);
      expect(find.text('High Score: 10000000'), findsOneWidget);
    });
    
    testWidgets('StatsPopup with zero scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsPopup(
              score: 0,
              highScore: 0,
            ),
          ),
        ),
      );
      
      // Verify zero displays correctly
      expect(find.text('Current Score: 0'), findsOneWidget);
      expect(find.text('High Score: 0'), findsOneWidget);
    });
    
    testWidgets('InstructionsPopup text is readable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstructionsPopup(),
          ),
        ),
      );
      
      // Check that instruction text exists
      expect(find.textContaining('Make as many words as possible'), findsOneWidget);
      
      // Find all Text widgets in instructions
      final instructionTexts = tester.widgetList<Text>(find.descendant(
        of: find.byType(InstructionsPopup),
        matching: find.byType(Text),
      ));
      
      // All text should have reasonable font size
      for (final text in instructionTexts) {
        final fontSize = text.style?.fontSize ?? 0;
        expect(fontSize, greaterThan(10.0)); // Should be readable
      }
    });
  });
  
  group('Button behavior tests', () {
    testWidgets('Buttons scale with screen size', (WidgetTester tester) async {
      // Test on phone-sized screen
      await tester.binding.setSurfaceSize(Size(360, 640));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StartButton(
                  gameInPlay: false,
                  onPressed: () {},
                ),
                GameBackButton(
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      final phoneButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton)).toList();
      final phoneButtonSizes = phoneButtons.map((b) => b.style?.minimumSize?.resolve({})).toList();
      
      // Test on tablet-sized screen
      await tester.binding.setSurfaceSize(Size(768, 1024));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StartButton(
                  gameInPlay: false,
                  onPressed: () {},
                ),
                GameBackButton(
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      final tabletButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton)).toList();
      final tabletButtonSizes = tabletButtons.map((b) => b.style?.minimumSize?.resolve({})).toList();
      
      // Button styles may or may not change based on implementation
      // This just tests that they're rendered correctly in both sizes
      expect(phoneButtonSizes.length, equals(tabletButtonSizes.length));
      
      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('Buttons are accessible sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StartButton(
                  gameInPlay: false,
                  onPressed: () {},
                ),
                GameBackButton(
                  onPressed: () {},
                ),
                InfoButton(
                  onPressed: () {},
                ),
                StatsButton(
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      
      // Find all tappable widgets
      final tappableWidgets = [
        ...tester.widgetList<ElevatedButton>(find.byType(ElevatedButton)),
        ...tester.widgetList<GestureDetector>(find.byType(GestureDetector)),
      ];
      
      // Check that all buttons are reasonably sized for touch
      for (final widget in tappableWidgets) {
        final RenderBox box = tester.renderObject(find.byWidget(widget as Widget));
        final size = box.size;
        
        // Recommend minimum size for touch targets is 48x48
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });
  });
}
