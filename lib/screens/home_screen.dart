import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper method to calculate responsive font size
  double _getResponsiveFontSize(BuildContext context, {double baseSize = 14, double scaleFactor = 0.04}) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    return baseSize + shortestSide * scaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    
    // Calculate responsive dimensions - make button bigger
    final double headerHeight = screenSize.height * (isLandscape ? 0.12 : 0.07);
    final double buttonMinSize = screenSize.shortestSide * 0.25; // Increased from 0.15
    final double buttonMaxSize = screenSize.shortestSide * 0.5;  // Increased from 0.4
    
    // Constrain button size within reasonable limits
    final double buttonSize = buttonMinSize.clamp(80.0, buttonMaxSize); // Minimum increased from 60 to 80
    
    return Scaffold(
      body: Column(
        children: [
          // Removed the "World of Web games" header
          
          // Content area with game button - now expanded to full height
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/lettris');
                },
                child: Container(
                  width: buttonSize * 3.0,
                  height: buttonSize * 1.2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7DFA), Color(0xFF1A4FBD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A4FBD).withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16), // Increased from 12
                  child: Center(
                    child: Text(
                      'Lettris',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, baseSize: 32, scaleFactor: 0.05),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Footer area
          Container(
            width: double.infinity,
            height: headerHeight * 0.7,
            color: const Color(0xFF2E7DFA).withOpacity(0.1),
            child: Center(
              child: Text(
                "Tap to start playing",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, baseSize: 14, scaleFactor: 0.01),
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF1A4FBD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
