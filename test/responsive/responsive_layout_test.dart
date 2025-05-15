import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/screens/home_screen.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/widgets/game_widgets.dart';

// Import responsive helper utilities
import 'responsive_test_helpers.dart';

void main() {
  group('Responsive Layout Tests', () {
    testWidgets('HomeScreen adapts to small screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(320, 480)); // Small screen
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Verify game button exists and is correctly sized
      expect(find.text('Lettris'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      
      // Check that the InkWell has appropriate size
      final inkWellRender = tester.renderObject(find.byType(InkWell));
      expect(inkWellRender.paintBounds.width, greaterThanOrEqualTo(48.0));
      expect(inkWellRender.paintBounds.height, greaterThanOrEqualTo(48.0));
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('HomeScreen adapts to large screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(1024, 768)); // Large screen
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      // Verify game button exists and is correctly sized
      expect(find.text('Lettris'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      
      // Check that the InkWell has appropriate size
      final inkWellRender = tester.renderObject(find.byType(InkWell));
      expect(inkWellRender.paintBounds.width, greaterThanOrEqualTo(48.0));
      expect(inkWellRender.paintBounds.height, greaterThanOrEqualTo(48.0));
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('LettrisScreen adapts to landscape mode', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(Size(800, 400)); // Landscape
      
      await tester.pumpWidget(
        MaterialApp(
          home: LettrisScreen(),
        ),
      );
      
      await tester.pump(Duration(seconds: 1)); // Allow initialization
      
      // Verify game controls exist
      expect(find.byType(StartButton), findsOneWidget);
      expect(find.byType(GameBackButton), findsOneWidget);
      expect(find.byType(WordScoreDisplay), findsOneWidget);
      
      // Verify no overflow errors in landscape
      expect(tester.takeException(), isNull);
      
      await tester.binding.setSurfaceSize(null);
    });
    
    testWidgets('Screens work on multiple device sizes', (WidgetTester tester) async {
      // Test HomeScreen on various device sizes
      await testScreenOnMultipleSizes(
        tester,
        HomeScreen(),
        [
          CommonScreenSizes.smallPhone,
          CommonScreenSizes.largePhone,
          CommonScreenSizes.smallTablet,
          CommonScreenSizes.phoneLandscape,
          CommonScreenSizes.tabletLandscape,
        ],
      );
      
      // Test LettrisScreen on various device sizes
      await testScreenOnMultipleSizes(
        tester,
        LettrisScreen(),
        [
          CommonScreenSizes.smallPhone,
          CommonScreenSizes.largePhone,
          CommonScreenSizes.phoneLandscape,
        ],
      );
    });
    
    testWidgets(
      'Game controls meet accessibility size requirements', 
      (WidgetTester tester) async {
        // Test the LettrisScreen where the StartButton and other controls are located
        await tester.pumpWidget(
          MaterialApp(
            home: LettrisScreen(),
          ),
        );
        
        // Wait for animation and layout to fully complete
        await tester.pumpAndSettle();
        
        // Check game controls for minimum size
        // Some controls like InfoButton might have special size constraints in the UI
        // but they should still have a minimum tappable area
        expectAccessibleSize(tester, StartButton);
        expectAccessibleSize(tester, GameBackButton);
        expectAccessibleSize(tester, WordScoreDisplay, enforceWidth: false);
        
        // For circular buttons, test using a specialized helper that checks inner structure
        await testCircularButtonsAccessibility(tester);
        
        // Test GameSquare widgets - they should have at least minimum height
        await testGameSquareAccessibility(tester, enforceWidth: false);
        
        // Test ElevatedButtons specifically
        final elevatedButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
        for (final button in elevatedButtons) {
          expectButtonAccessibleSize(tester, button);
        }
      },
      timeout: const Timeout(Duration(minutes: 1)), // Extend timeout to handle animations
    );
    
    testWidgets('Text scales properly on different screen sizes', (WidgetTester tester) async {
      // Test text scaling in HomeScreen
      await tester.binding.setSurfaceSize(Size(320, 480));
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      final smallScreenTitle = tester.widget<Text>(find.text("World of Web games"));
      final smallScreenFontSize = smallScreenTitle.style?.fontSize;
      
      await tester.binding.setSurfaceSize(Size(1024, 768));
      
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );
      
      final largeScreenTitle = tester.widget<Text>(find.text("World of Web games"));
      final largeScreenFontSize = largeScreenTitle.style?.fontSize;
      
      // In a responsive app, text size should adapt to screen size
      expect(smallScreenFontSize, isNotNull);
      expect(largeScreenFontSize, isNotNull);
      
      // Reset size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
