import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays game title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('World of Web games'), findsOneWidget);
  });

  testWidgets('HomeScreen displays game button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Lettris'), findsOneWidget);
  });

  testWidgets('HomeScreen displays footer text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Tap a game to start playing'), findsOneWidget);
  });

  testWidgets('HomeScreen navigates to Lettris screen when button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (context) => HomeScreen(),
          '/lettris': (context) => Scaffold(body: Text('Lettris Game Screen')),
        },
      ),
    );

    await tester.tap(find.text('Lettris'));
    await tester.pumpAndSettle();

    expect(find.text('Lettris Game Screen'), findsOneWidget);
  });

  testWidgets('HomeScreen adapts to different screen sizes', (WidgetTester tester) async {
    // Test with phone size
    final phoneSize = Size(375, 667);
    await tester.binding.setSurfaceSize(phoneSize);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify responsive layout elements
    expect(find.text('World of Web games'), findsOneWidget);
    expect(find.text('Lettris'), findsOneWidget);

    // Test with tablet size
    final tabletSize = Size(800, 1024);
    await tester.binding.setSurfaceSize(tabletSize);
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify responsive layout still works
    expect(find.text('World of Web games'), findsOneWidget);
    expect(find.text('Lettris'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('HomeScreen handles orientation changes', (WidgetTester tester) async {
    // Test portrait orientation
    await tester.binding.setSurfaceSize(Size(400, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('World of Web games'), findsOneWidget);
    expect(find.text('Lettris'), findsOneWidget);

    // Test landscape orientation
    await tester.binding.setSurfaceSize(Size(800, 400));
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('World of Web games'), findsOneWidget);
    expect(find.text('Lettris'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });
}
