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
    
    // Calculate responsive dimensions
    final double headerHeight = screenSize.height * (isLandscape ? 0.12 : 0.07);
    final double buttonMinSize = screenSize.shortestSide * 0.15;
    final double buttonMaxSize = screenSize.shortestSide * 0.4;
    
    // Constrain button size within reasonable limits
    final double buttonSize = buttonMinSize.clamp(60.0, buttonMaxSize);
    
    return Scaffold(
      body: Column(
        children: [
          // Header with game title
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: headerHeight,
            child: Center(
              child: Text(
                "World of Web games",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getResponsiveFontSize(context, baseSize: 18, scaleFactor: 0.02),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Content area with game button
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/lettris');
                },
                child: Container(
                  width: buttonSize * 2.5,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      'Lettris',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, baseSize: 22, scaleFactor: 0.03),
                        fontWeight: FontWeight.bold,
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
            color: Colors.grey.withOpacity(0.2),
            child: Center(
              child: Text(
                "Tap a game to start playing",
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, baseSize: 14, scaleFactor: 0.01),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
