import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettris/screens/home_screen.dart';
import 'package:lettris/screens/lettris_screen.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Allow both portrait and landscape orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize dictionary in the background
  _initializeDictionary();
  
  // Start the app
  runApp(const LettrisApp());
}

// Initialize dictionary asynchronously to avoid blocking the UI
Future<void> _initializeDictionary() async {
  try {
    if (kDebugMode) {
      print('Starting dictionary initialization...');
      final stopwatch = Stopwatch()..start();
      
      await loadDictionary();
      
      stopwatch.stop();
      print('Dictionary initialized in ${stopwatch.elapsedMilliseconds}ms');
    } else {
      // In release mode, just load without logging
      await loadDictionary();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing dictionary: $e');
    }
    
    // Retry with a delay if initialization fails
    Future.delayed(const Duration(seconds: 3), () {
      _initializeDictionary();
    });
  }
}

class LettrisApp extends StatelessWidget {
  const LettrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A2Z Games',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7DFA)),
        primaryColor: const Color(0xFF2E7DFA),
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
