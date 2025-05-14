import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettris/screens/home_screen.dart';
import 'package:lettris/screens/lettris_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/lettris': (context) => const LettrisScreen(),
      },
      initialRoute: '/',
    );
  }
}
