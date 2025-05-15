import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/widgets/game_widgets.dart';

/// Helper function to verify a widget meets minimum accessibility size requirements
void expectAccessibleSize(WidgetTester tester, Type widgetType, {
  double minWidth = 48.0, 
  double minHeight = 48.0,
  bool enforceWidth = true,
  bool enforceHeight = true,
}) {
  final widget = find.byType(widgetType);
  expect(widget, findsOneWidget, reason: "$widgetType not found");
  
  final renderObject = tester.renderObject(widget);
  final size = renderObject.paintBounds.size;
  
  if (enforceWidth) {
    expect(size.width, greaterThanOrEqualTo(minWidth), 
      reason: "$widgetType width (${size.width}) is smaller than required minimum ($minWidth)");
  }
  
  if (enforceHeight) {
    expect(size.height, greaterThanOrEqualTo(minHeight), 
      reason: "$widgetType height (${size.height}) is smaller than required minimum ($minHeight)");
  }
}

/// Helper function to verify ElevatedButton minimumSize configuration
void expectButtonAccessibleSize(WidgetTester tester, ElevatedButton button, {double minWidth = 48.0, double minHeight = 48.0}) {
  final buttonSize = button.style?.minimumSize?.resolve({});
  
  expect(buttonSize?.width, greaterThanOrEqualTo(minWidth),
    reason: "ElevatedButton width (${buttonSize?.width}) is smaller than required minimum ($minWidth)");
  expect(buttonSize?.height, greaterThanOrEqualTo(minHeight),
    reason: "ElevatedButton height (${buttonSize?.height}) is smaller than required minimum ($minHeight)");
}

/// Tests if a screen layout works on different screen sizes without overflow errors
Future<void> testScreenOnMultipleSizes(
  WidgetTester tester, 
  Widget screen,
  List<Size> screenSizes
) async {
  for (final size in screenSizes) {
    await tester.binding.setSurfaceSize(size);
    
    await tester.pumpWidget(
      MaterialApp(
        home: screen,
      ),
    );
    
    // Allow time for layout to complete
    await tester.pump(Duration(milliseconds: 500));
    
    // Verify no overflow errors
    expect(tester.takeException(), isNull, 
      reason: "Layout overflow detected on screen size ${size.width}x${size.height}");
  }
  
  // Reset surface size
  await tester.binding.setSurfaceSize(null);
}

/// Helper function to test if GameSquare widgets meet accessibility standards
Future<void> testGameSquareAccessibility(WidgetTester tester, {
  bool enforceWidth = true,
  bool enforceHeight = true,
}) async {
  final gameSquares = tester.widgetList<GameSquare>(find.byType(GameSquare));
  expect(gameSquares.length, greaterThan(0), reason: "No GameSquare widgets found");
  
  // Test a few GameSquares for minimum touch size
  for (int i = 0; i < min(5, gameSquares.length); i++) {
    final squareRender = tester.renderObject(find.byWidget(gameSquares.elementAt(i)));
    
    if (enforceWidth) {
      expect(squareRender.paintBounds.width, greaterThanOrEqualTo(48.0), 
            reason: "GameSquare width too small: ${squareRender.paintBounds.width}");
    }
    
    if (enforceHeight) {
      expect(squareRender.paintBounds.height, greaterThanOrEqualTo(48.0), 
            reason: "GameSquare height too small: ${squareRender.paintBounds.height}");
    }
  }
}

/// Tests interactive widgets directly rather than using paintBounds
Future<void> testCircularButtonsAccessibility(WidgetTester tester) async {
  // Find the individual widgets
  final InfoButton infoButton = tester.widget<InfoButton>(find.byType(InfoButton).first);
  final StatsButton statsButton = tester.widget<StatsButton>(find.byType(StatsButton).first);
  
  // Get the GestureDetectors to check tap areas
  final infoGesture = tester.widget<GestureDetector>(
    find.descendant(
      of: find.byType(InfoButton).first,
      matching: find.byType(GestureDetector),
    ),
  );
  
  final statsGesture = tester.widget<GestureDetector>(
    find.descendant(
      of: find.byType(StatsButton).first,
      matching: find.byType(GestureDetector),
    ),
  );
  
  // Check that the GestureDetector uses opaque hit testing
  expect(infoGesture.behavior, equals(HitTestBehavior.opaque),
    reason: "InfoButton should use HitTestBehavior.opaque for reliable touch area");
  expect(statsGesture.behavior, equals(HitTestBehavior.opaque),
    reason: "StatsButton should use HitTestBehavior.opaque for reliable touch area");
  
  // Find the SizedBox to check actual dimensions
  final infoSizedBox = tester.widget<SizedBox>(
    find.descendant(
      of: find.byType(InfoButton).first,
      matching: find.byType(SizedBox),
    ),
  );
  
  final statsSizedBox = tester.widget<SizedBox>(
    find.descendant(
      of: find.byType(StatsButton).first,
      matching: find.byType(SizedBox),
    ),
  );
  
  // Verify SizedBox dimensions meet accessibility requirements
  expect(infoSizedBox.width, equals(48.0), reason: "InfoButton SizedBox width should be 48.0");
  expect(infoSizedBox.height, equals(48.0), reason: "InfoButton SizedBox height should be 48.0");
  expect(statsSizedBox.width, equals(48.0), reason: "StatsButton SizedBox width should be 48.0");
  expect(statsSizedBox.height, equals(48.0), reason: "StatsButton SizedBox height should be 48.0");
}

/// Common screen sizes for testing responsive layouts
class CommonScreenSizes {
  static const Size smallPhone = Size(320, 568);    // iPhone SE
  static const Size mediumPhone = Size(375, 667);   // iPhone 8
  static const Size largePhone = Size(414, 896);    // iPhone 11 Pro Max
  static const Size smallTablet = Size(768, 1024);  // iPad
  static const Size largeTablet = Size(1024, 1366); // iPad Pro
  
  static const Size phoneLandscape = Size(740, 360);
  static const Size tabletLandscape = Size(1024, 768);
  
  static const List<Size> allPhones = [smallPhone, mediumPhone, largePhone];
  static const List<Size> allTablets = [smallTablet, largeTablet];
  static const List<Size> allSizes = [smallPhone, mediumPhone, largePhone, smallTablet, largeTablet];
  static const List<Size> allLandscapes = [phoneLandscape, tabletLandscape];
}

// Helper function to get the minimum of two values
int min(int a, int b) => a < b ? a : b;