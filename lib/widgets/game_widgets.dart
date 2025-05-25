import 'package:flutter/material.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:lettris/utils/dictionary/dictionary_loader.dart';
import 'package:lettris/utils/dictionary/word_dictionary.dart';

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
    // Generate colors based on letter
    final int letterCode = letter.isEmpty ? 0 : letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    final double hue = (letterCode * 13.85) % 360;
    
    final Color normalColor = letter.isEmpty 
        ? Colors.grey[200]!
        : HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
    
    final Color selectedColor = letter.isEmpty
        ? Colors.grey[200]!
        : HSLColor.fromAHSL(1.0, hue, 0.7, 0.8).toColor();

    return GestureDetector(
      onTap: (selected || letter.isEmpty)? null : onTap,
      child: AnimatedContainer(
        // Animation duration
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        
        // Add minimum constraints for better accessibility
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        
        // Animated properties
        decoration: BoxDecoration(
          color: selected ? selectedColor : normalColor,
          border: letter.isEmpty ? null : Border.all(
            color: Colors.black,
            width: selected ? 1.0 : 0.5, // Animated border width: 0.5px to 1px
          ),
          borderRadius: BorderRadius.circular(4),
          // Add shadow animation for selection
          boxShadow: selected ? [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ] : null,
        ),
        
        // Optional: Animate size for emphasis
        transform: selected 
            ? (Matrix4.identity()..scale(1.05)) 
            : Matrix4.identity(),
        
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.white,
              fontSize: selected ? fontSize * 1.1 : fontSize, // Animate text size
              fontWeight: FontWeight.bold,
            ),
            child: Text(letter),
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
        backgroundColor: const Color(0xFF1A4FBD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        minimumSize: const Size(60, 48),
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
          color: displayClickable ? const Color(0xFF1A4FBD) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        // Ensure minimum height for accessibility
        constraints: const BoxConstraints(minHeight: 48.0),
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
        backgroundColor: const Color(0xFF1A4FBD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        minimumSize: const Size(60, 48),
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
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure a minimum size of 48px for accessibility
    final double accessibleSize = 48.0;
    
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque, // Extend the touchable area
      child: SizedBox(
        width: accessibleSize,
        height: accessibleSize,
        child: Center(
          child: Container(
            width: size < accessibleSize ? size : accessibleSize,
            height: size < accessibleSize ? size : accessibleSize,
            decoration: BoxDecoration(
              color: const Color(0xFF1A4FBD),
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
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure a minimum size of 48px for accessibility
    final double accessibleSize = 48.0;
    
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque, // Extend the touchable area
      child: SizedBox(
        width: accessibleSize,
        height: accessibleSize,
        child: Center(
          child: Container(
            width: size < accessibleSize ? size : accessibleSize,
            height: size < accessibleSize ? size : accessibleSize,
            decoration: BoxDecoration(
              color: const Color(0xFF1A4FBD),
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

// Stats Popup Widget - Now with recent words
class StatsPopup extends StatefulWidget {
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
  State<StatsPopup> createState() => _StatsPopupState();
}

class _StatsPopupState extends State<StatsPopup> {
  List<String> recentWords = [];
  bool isLoading = true;
  bool isResettingDictionary = false;
  int wordCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentWords();
  }

  Future<void> _loadRecentWords() async {
    try {
      final words = await getRecentWords();
      
      // Get the word count if dictionary is initialized
      int count = 0;
      if (DictionaryLoader.instance.isInitialized) {
        try {
          count = await WordDictionary().getWordCount();
        } catch (e) {
          // Ignore errors
        }
      }
      
      if (mounted) {
        setState(() {
          recentWords = words;
          wordCount = count;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  Future<void> _resetDictionary() async {
    setState(() {
      isResettingDictionary = true;
    });
    
    try {
      // Reset the dictionary
      await DictionaryLoader.instance.resetDictionary();
      
      // Reload recent words
      await _loadRecentWords();
      
      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dictionary reset successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting dictionary: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isResettingDictionary = false;
        });
      }
    }
  }

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
              fontSize: widget.fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            "Current Score: ${widget.score}",
            style: TextStyle(fontSize: widget.fontSize),
          ),
          Text(
            "High Score: ${widget.highScore}",
            style: TextStyle(fontSize: widget.fontSize),
          ),
          const SizedBox(height: 8),
          Text(
            "Dictionary Words: $wordCount",
            style: TextStyle(fontSize: widget.fontSize * 0.9),
          ),
          const SizedBox(height: 20),
          // Add a button to reset the dictionary (useful for development)
          if (isResettingDictionary)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            ElevatedButton(
              onPressed: _resetDictionary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: Text(
                "Reset Dictionary",
                style: TextStyle(fontSize: widget.fontSize * 0.9),
              ),
            ),
          Text(
            "Recent Words:",
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const SizedBox(
              height: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (recentWords.isEmpty)
            Text(
              "No words found yet",
              style: TextStyle(
                fontSize: widget.fontSize * 0.9,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              children: recentWords.take(10).map((word) {
                // Generate a color based on the word's first letter
                final int letterCode = word[0].codeUnitAt(0) - 'A'.codeUnitAt(0);
                final double hue = (letterCode * 13.85) % 360;
                final Color chipColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
                
                return Chip(
                  label: Text(
                    word,
                    style: TextStyle(
                      fontSize: widget.fontSize * 0.9,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: chipColor,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
