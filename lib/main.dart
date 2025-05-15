import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettris/screens/home_screen.dart';
import 'package:lettris/screens/lettris_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Allow both portrait and landscape orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const LettrisApp());
}

class LettrisApp extends StatelessWidget {
  const LettrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A2Z Games',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
        // Add responsive text theme
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          bodyLarge: TextStyle(fontSize: 16),
          titleMedium: TextStyle(fontSize: 18),
          titleLarge: TextStyle(fontSize: 22),
          headlineMedium: TextStyle(fontSize: 24),
        ),
        // Make buttons more touch-friendly
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(80, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/lettris': (context) => const LettrisScreen(),
      },
      initialRoute: '/',
      // Add error handling for navigation
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}
