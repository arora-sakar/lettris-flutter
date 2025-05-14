import 'package:flutter/material.dart';

// Square widget for the game grid
class GameSquare extends StatelessWidget {
  final String letter;
  final bool selected;
  final VoidCallback onTap;

  const GameSquare({
    super.key,
    required this.letter,
    required this.selected,
    required this.onTap,
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
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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

  const StartButton({
    super.key,
    required this.gameInPlay,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
      ),
      child: Text(gameInPlay ? "PAUSE" : "START"),
    );
  }
}

// Word display and score widget
class WordScoreDisplay extends StatelessWidget {
  final String displayText;
  final bool displayClickable;
  final VoidCallback onTap;

  const WordScoreDisplay({
    super.key,
    required this.displayText,
    required this.displayClickable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: displayClickable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: displayClickable ? Colors.grey[600] : Colors.white,
          border: Border.all(color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              color: displayClickable ? Colors.white : Colors.black,
              fontSize: 18,
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

  const GameBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
      ),
      child: const Text("BACK"),
    );
  }
}

// Info button widget
class InfoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const InfoButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
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

  const StatsButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
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

  const GameOverPopup({
    super.key,
    required this.score,
    required this.highScore,
    required this.onOkPressed,
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
          const Text(
            "GAME OVER !!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text("Your Score: $score"),
          Text("High Score: $highScore"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onOkPressed,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// Instructions Popup Widget
class InstructionsPopup extends StatelessWidget {
  const InstructionsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "HOW TO PLAY",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const Text(
              "Make as many words as possible before space for falling alphabets runs out.",
            ),
            const SizedBox(height: 16),
            const Text("• Press START/PAUSE to start or pause the game."),
            const Text("• Press the alphabets A-Z that you want to append to your word."),
            const Text("• Press BACK to remove letter from the end of the word."),
            const Text("• The word is displayed in a word box between START and BACK."),
            const Text("• As soon as a valid word of 3 or more alphabets is formed, word box becomes pressable."),
            const Text("• Press it to clear the selected alphabets."),
            const Text("• The bigger the word the more points you get for it."),
          ],
        ),
      ),
    );
  }
}

// Stats Popup Widget
class StatsPopup extends StatelessWidget {
  final int score;
  final int highScore;

  const StatsPopup({
    super.key,
    required this.score,
    required this.highScore,
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
          const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text("Current Score: $score"),
          Text("High Score: $highScore"),
        ],
      ),
    );
  }
}
