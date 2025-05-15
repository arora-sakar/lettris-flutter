import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/widgets/game_widgets.dart';

void main() {
  group('GameSquare widget tests', () {
    testWidgets('GameSquare displays letter correctly', (WidgetTester tester) async {
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
    });

    testWidgets('GameSquare has different color when selected', (WidgetTester tester) async {
      // Test unselected state
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

      final unselectedContainer = tester.widget<Container>(find.ancestor(
        of: find.text('A'),
        matching: find.byType(Container),
      ).first);
      
      final unselectedColor = (unselectedContainer.decoration as BoxDecoration).color;

      // Test selected state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final selectedContainer = tester.widget<Container>(find.ancestor(
        of: find.text('A'),
        matching: find.byType(Container),
      ).first);
      
      final selectedColor = (selectedContainer.decoration as BoxDecoration).color;

      // Colors should be different
      expect(selectedColor, isNot(equals(unselectedColor)));
    });

    testWidgets('GameSquare handles empty letter correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: '',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      
      // Empty squares should have a different appearance
      expect(decoration.border, isNull);
    });

    testWidgets('GameSquare calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('Selected GameSquare does not call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameSquare(
              letter: 'A',
              selected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isFalse);
    });
  });

  group('StartButton widget tests', () {
    testWidgets('StartButton shows START when game is not in play', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartButton(
              gameInPlay: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('START'), findsOneWidget);
      expect(find.text('PAUSE'), findsNothing);
    });

    testWidgets('StartButton shows PAUSE when game is in play', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartButton(
              gameInPlay: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('START'), findsNothing);
      expect(find.text('PAUSE'), findsOneWidget);
    });

    testWidgets('StartButton calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartButton(
              gameInPlay: false,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });
  });

  group('WordScoreDisplay widget tests', () {
    testWidgets('WordScoreDisplay shows the display text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordScoreDisplay(
              displayText: 'TEST',
              displayClickable: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('TEST'), findsOneWidget);
    });

    testWidgets('WordScoreDisplay changes appearance when clickable', (WidgetTester tester) async {
      // Test non-clickable state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordScoreDisplay(
              displayText: 'TEST',
              displayClickable: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final nonClickableContainer = tester.widget<Container>(find.ancestor(
        of: find.text('TEST'),
        matching: find.byType(Container),
      ).first);
      
      final nonClickableColor = (nonClickableContainer.decoration as BoxDecoration).color;

      // Test clickable state
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

      final clickableContainer = tester.widget<Container>(find.ancestor(
        of: find.text('TEST'),
        matching: find.byType(Container),
      ).first);
      
      final clickableColor = (clickableContainer.decoration as BoxDecoration).color;

      // Colors should be different
      expect(clickableColor, isNot(equals(nonClickableColor)));
    });

    testWidgets('WordScoreDisplay calls onTap when clickable and tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordScoreDisplay(
              displayText: 'TEST',
              displayClickable: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('WordScoreDisplay does not call onTap when not clickable', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordScoreDisplay(
              displayText: 'TEST',
              displayClickable: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isFalse);
    });
  });

  group('GameBackButton widget tests', () {
    testWidgets('GameBackButton displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBackButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('GameBackButton calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBackButton(
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });
  });

  group('InfoButton and StatsButton tests', () {
    testWidgets('InfoButton displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('StatsButton displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('Buttons call onPressed when tapped', (WidgetTester tester) async {
      bool infoPressed = false;
      bool statsPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                InfoButton(
                  onPressed: () {
                    infoPressed = true;
                  },
                ),
                StatsButton(
                  onPressed: () {
                    statsPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('i'));
      expect(infoPressed, isTrue);
      
      await tester.tap(find.text('...'));
      expect(statsPressed, isTrue);
    });
  });

  group('Popup widget tests', () {
    testWidgets('GameOverPopup displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverPopup(
              score: 100,
              highScore: 150,
              onOkPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('GAME OVER !!'), findsOneWidget);
      expect(find.text('Your Score: 100'), findsOneWidget);
      expect(find.text('High Score: 150'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('InstructionsPopup displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstructionsPopup(),
          ),
        ),
      );

      expect(find.text('HOW TO PLAY'), findsOneWidget);
      // Check for at least one instruction
      expect(find.textContaining('Press START/PAUSE'), findsOneWidget);
    });

    testWidgets('StatsPopup displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsPopup(
              score: 100,
              highScore: 150,
            ),
          ),
        ),
      );

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Current Score: 100'), findsOneWidget);
      expect(find.text('High Score: 150'), findsOneWidget);
    });
  });
}
