import 'package:flutter/material.dart';

// Square widget for the game grid
class GameSquare extends StatelessWidget {
  final String letter;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;

  const GameSquare({
    super.key,
    required this.letter,
    required this.selected,
    required this.onTap,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    String squareClass = '';
    Color backgroundColor = Colors.grey[200]!;
    BoxBorder? border;

    if (letter.isEmpty) {
      squareClass = "empty-square";
      backgroundColor = Colors.grey[200]!;
      border = null;
    } else {
      // Generate a color based on the letter
      final int letterCode = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
      final double hue = (letterCode * 13.85) % 360; // Distribute colors around the hue wheel
      
      if (selected) {
        backgroundColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.8).toColor();
        border = Border.all(color: Colors.black, width: 1, style: BorderStyle.solid);
      } else {
        backgroundColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
        border = Border.all(color: Colors.black, width: 1, style: BorderStyle.solid);
      }
    }

    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Start/Pause button widget
class StartButton extends StatelessWidget {
  final bool gameInPlay;
  final VoidCallback onPressed;
  final double fontSize;

  const StartButton({
    super.key,
    required this.gameInPlay,
    required this.onPressed,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        minimumSize: const Size(60, 40),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          gameInPlay ? "PAUSE" : "START",
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}

// Word display and score widget
class WordScoreDisplay extends StatelessWidget {
  final String displayText;
  final bool displayClickable;
  final VoidCallback onTap;
  final double fontSize;

  const WordScoreDisplay({
    super.key,
    required this.displayText,
    required this.displayClickable,
    required this.onTap,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: displayClickable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: displayClickable ? Colors.grey[600] : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Center(
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: displayClickable ? Colors.white : Colors.black,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom back button widget to remove letters
class GameBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double fontSize;

  const GameBackButton({
    super.key,
    required this.onPressed,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        minimumSize: const Size(60, 40),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "BACK",
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}

// Info button widget
class InfoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const InfoButton({
    super.key,
    required this.onPressed,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            "i",
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

// Stats button widget
class StatsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const StatsButton({
    super.key,
    required this.onPressed,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            "...",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Game Over Popup Widget
class GameOverPopup extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onOkPressed;
  final double fontSize;

  const GameOverPopup({
    super.key,
    required this.score,
    required this.highScore,
    required this.onOkPressed,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "GAME OVER !!",
            style: TextStyle(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            "Your Score: $score",
            style: TextStyle(fontSize: fontSize),
          ),
          Text(
            "High Score: $highScore",
            style: TextStyle(fontSize: fontSize),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onOkPressed,
            child: Text(
              "OK",
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

// Instructions Popup Widget
class InstructionsPopup extends StatelessWidget {
  final double fontSize;

  const InstructionsPopup({
    super.key,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "HOW TO PLAY",
              style: TextStyle(
                fontSize: fontSize * 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          Text(
            "Make as many words as possible before space for falling alphabets runs out.",
            style: TextStyle(fontSize: fontSize),
          ),
          const SizedBox(height: 16),
          Text("• Press START/PAUSE to start or pause the game.", style: TextStyle(fontSize: fontSize)),
          Text("• Press the alphabets A-Z that you want to append to your word.", style: TextStyle(fontSize: fontSize)),
          Text("• Press BACK to remove letter from the end of the word.", style: TextStyle(fontSize: fontSize)),
          Text("• The word is displayed in a word box between START and BACK.", style: TextStyle(fontSize: fontSize)),
          Text("• As soon as a valid word of 3 or more alphabets is formed, word box becomes pressable.", style: TextStyle(fontSize: fontSize)),
          Text("• Press it to clear the selected alphabets.", style: TextStyle(fontSize: fontSize)),
          Text("• The bigger the word the more points you get for it.", style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }
}

// Stats Popup Widget
class StatsPopup extends StatelessWidget {
  final int score;
  final int highScore;
  final double fontSize;

  const StatsPopup({
    super.key,
    required this.score,
    required this.highScore,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Statistics",
            style: TextStyle(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            "Current Score: $score",
            style: TextStyle(fontSize: fontSize),
          ),
          Text(
            "High Score: $highScore",
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
