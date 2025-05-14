import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lettris/utils/game_utils.dart';
import 'package:lettris/widgets/game_widgets.dart';

class LettrisScreen extends StatefulWidget {
  const LettrisScreen({super.key});

  @override
  LettrisScreenState createState() => LettrisScreenState();
}

class LettrisScreenState extends State<LettrisScreen> {
  // Grid dimensions and counts
  static const int gridWidth = 10;
  static const int gridHeight = 18;
  static const int totalSquares = gridWidth * gridHeight;
  
  // Game state variables
  List<Square> squareArray = [];
  List<bool> selected = List.filled(totalSquares, false);
  List<String> letters = List.filled(totalSquares, '');
  List<Square> selectedSquares = [];
  List<Square> fallingSquares = [];
  List<String> wordScoreDisplayText = [];
  String displayText = '';
  bool displayClickable = false;
  bool gameInPlay = false;
  bool gameOver = false;
  bool instPopupShow = false;
  bool statPopupShow = false;
  int score = 0;
  int highScore = 0;
  Timer? timer;
  bool instPopupShowDuringGamePlay = false;
  bool statPopupShowDuringGamePlay = false;
  
  // Performance optimizations
  Timer? _validationDebounce;
  final Map<String, bool> _wordValidationCache = {}; // In-memory cache

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    _validationDebounce?.cancel();
    super.dispose();
  }
  
  // Override to check and fix display clickable state when rendering
  @override
  void didUpdateWidget(LettrisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Safety check for valid words that may not have been marked clickable
    if (!displayClickable && wordScoreDisplayText.length >= 3) {
      final word = wordScoreDisplayText.join('');
      if (_wordValidationCache.containsKey(word) && _wordValidationCache[word]!) {
        // Fix inconsistent state if we know the word is valid
        Future.microtask(() {
          if (mounted && word == wordScoreDisplayText.join('')) {
            setState(() {
              displayClickable = true;
            });
          }
        });
      }
    }
  }

  // Initialize game data
  Future<void> _initializeGame() async {
    // Initialize square array
    for (int i = 0; i < totalSquares; i++) {
      squareArray.add(Square(index: i));
    }
    
    // Load dictionary
    await loadDictionary();
    
    // Get high score
    highScore = await getHighScore();
    
    setState(() {});
  }

  // Game control functions
  void pauseGame() {
    timer?.cancel();
    timer = null;
    setState(() {
      gameInPlay = false;
    });
  }

  void resumeGame() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (_) => updateGrid());
    setState(() {
      gameInPlay = true;
      instPopupShow = false;
      statPopupShow = false;
      gameOver = false;
    });
  }

  void resetGame() {
    fallingSquares = [];
    selectedSquares = [];
    wordScoreDisplayText = [];
    
    setState(() {
      score = 0;
      letters = List.filled(totalSquares, '');
      selected = List.filled(totalSquares, false);
      displayClickable = false;
      displayText = '';
      gameOver = false;
      gameInPlay = false;
    });
    
    // Reset square array
    squareArray = [];
    for (int i = 0; i < totalSquares; i++) {
      squareArray.add(Square(index: i));
    }
    
    // Add initial falling squares even if game is not in play yet
    refreshFallingSquares();
    getGridState(); // Update UI to reflect the new squares
  }

  // Game mechanics functions
  void updateGrid() {
    moveFallingSquares();
    
    if (gameOver) {
      // Use a local variable to avoid creating multiple delayed callbacks
      if (timer != null) {
        timer?.cancel();
        timer = null;
        Future.delayed(const Duration(seconds: 10), resetGame);
      }
      return;
    }
    
    getGridState();
  }

  void refreshFallingSquares() {
    int i = 0;
    for (; i < gridWidth; i++) {
      if (squareArray[i].alphabet.isNotEmpty) {
        break;
      }
    }
    
    if (i < gridWidth) {
      pauseGame();
      setState(() {
        gameOver = true;
      });
      return;
    }
    
    final letterMap = <String, bool>{};
    for (i = 0; i < gridWidth; i++) {
      String a = '';
      do {
        a = getPseudorandomLetter();
      } while (letterMap.containsKey(a));
      
      letterMap[a] = true;
      squareArray[i].alphabet = a;
      fallingSquares.add(squareArray[i]);
    }
  }

  void moveFallingSquares() {
    List<Square> fallingSquaresNext = [];
    for (int i = 0; i < fallingSquares.length; i++) {
      if (fallingSquares[i].index ~/ gridWidth >= gridHeight - 1) {
        continue;
      }
      
      if (squareArray[fallingSquares[i].index + gridWidth].alphabet.isNotEmpty) {
        continue;
      }
      
      if (fallingSquares[i].alphabet.isEmpty) {
        continue;
      }
      
      squareArray[fallingSquares[i].index + gridWidth].alphabet = fallingSquares[i].alphabet;
        
      if (fallingSquares[i].selected > -1) {
        selectedSquares[fallingSquares[i].selected] = squareArray[fallingSquares[i].index + gridWidth];
      }
      
      squareArray[fallingSquares[i].index + gridWidth].selected = fallingSquares[i].selected;
        
      fallingSquares[i].alphabet = '';
      fallingSquares[i].selected = -1;
      fallingSquaresNext.add(squareArray[fallingSquares[i].index + gridWidth]);
    }
    
    if (fallingSquaresNext.isEmpty) {
      refreshFallingSquares();
      return;
    }
    
    fallingSquares = fallingSquaresNext;
  }

  void getGridState() {
    // Only update the cells that need to be updated instead of all cells
    final List<MapEntry<int, bool>> updatedCells = [];
    final List<String> updatedLetters = [];
    
    for (int i = 0; i < totalSquares; i++) {
      if (letters[i] != squareArray[i].alphabet || 
          selected[i] != (squareArray[i].selected > -1)) {
        updatedLetters.add(squareArray[i].alphabet);
        updatedCells.add(MapEntry(i, squareArray[i].selected > -1));
      }
    }
    
    if (updatedCells.isEmpty) return; // No updates needed
    
    setState(() {
      for (var i = 0; i < updatedCells.length; i++) {
        final index = updatedCells[i].key;
        letters[index] = squareArray[index].alphabet;
        selected[index] = updatedCells[i].value;
      }
    });
  }

  void dropUpperSquares(int index) {
    if (squareArray[index].selected == -1) {
      return;
    }
    
    while (index >= gridWidth && squareArray[index - gridWidth].alphabet.isNotEmpty) {
      if (squareArray[index - gridWidth].selected > -1) {
        dropUpperSquares(index - gridWidth);
      }
      
      squareArray[index].alphabet = squareArray[index - gridWidth].alphabet;
      squareArray[index].selected = squareArray[index - gridWidth].selected;
      index = index - gridWidth;
    }
    
    squareArray[index].alphabet = '';
    squareArray[index].selected = -1;
  }

  // UI Event handlers
  void handleStartButtonClick() {
    // If we're in a game over state, the start button should work normally
    // to allow the player to start a new game
    
    if (!gameInPlay) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void handleSquareClick(int i) {
    if (!gameInPlay || gameOver || squareArray[i].selected > -1) {
      return;
    }

    if (squareArray[i].alphabet.isEmpty && i + gridWidth < totalSquares && 
        squareArray[i + gridWidth].alphabet.isNotEmpty) {
      bool flag = false;
      for (final s in fallingSquares) {
        if (s.index == i + gridWidth) {
          flag = true;
          break;
        }
      }
      
      if (flag == false) {
        return;
      }
      
      i = i + gridWidth;
    }
    
    // Update data structures
    squareArray[i].selected = selectedSquares.length;
    selectedSquares.add(squareArray[i]);
    wordScoreDisplayText.add(squareArray[i].alphabet);
    String word = wordScoreDisplayText.join('');
    
    // Immediately update UI with the new letter
    setState(() {
      letters[i] = squareArray[i].alphabet;
      selected[i] = true;
      displayText = word;
    });
    
    // Validate word efficiently with cache
    _validateWord(word);
  }
  
  // Efficient word validation with cache and consistency protection
  void _validateWord(String word) {
    // Mark as validating in progress
    setState(() {
      // Assume not clickable until validation completes
      displayClickable = false;
    });
    
    // Check in-memory cache first (synchronous)
    if (_wordValidationCache.containsKey(word)) {
      final bool isValid = _wordValidationCache[word]!;
      
      // Ensure this update happens AFTER the UI has refreshed
      // from the previous setState call
      Future.microtask(() {
        if (mounted && word == wordScoreDisplayText.join('')) {
          setState(() {
            displayClickable = isValid;
          });
        }
      });
      return;
    }
    
    // Cancel any pending validation
    _validationDebounce?.cancel();
    
    // Store the word we're validating to prevent race conditions
    final String wordToValidate = word;
    
    // Debounce the validation
    _validationDebounce = Timer(const Duration(milliseconds: 50), () {
      checkValidWord(wordToValidate).then((isValid) {
        // Only update if this is still the current word and widget is mounted
        final String currentWord = wordScoreDisplayText.join('');
        if (mounted && wordToValidate == currentWord) {
          // Cache the result for future use
          _wordValidationCache[wordToValidate] = isValid;
          
          setState(() {
            displayClickable = isValid;
          });
          
          // Double-check consistency after a short delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && wordToValidate == wordScoreDisplayText.join('')) {
              setState(() {
                displayClickable = isValid;
              });
            }
          });
        }
      });
    });
  }

  void handleDisplayClick() {
    if (!gameInPlay || gameOver || !displayClickable) {
      return;
    }

    for (int i = 0; i < selectedSquares.length; i++) {
      dropUpperSquares(selectedSquares[i].index);
    }

    getGridState();
    
    int newScore = score + wordScoreDisplayText.length * 2;
    
    if (newScore > highScore) {
      saveHighScore(newScore);
      highScore = newScore;
    }

    setState(() {
      score = newScore;
    });
    
    // Clear word display in a separate state update to avoid conflicts
    clearWordDisplay();
  }
  
  // Helper method to clear word display with consistent state
  void clearWordDisplay() {
    setState(() {
      selectedSquares = [];
      wordScoreDisplayText = [];
      displayClickable = false;
      displayText = 'Score: $score';
    });
  }

  void handleBackButtonClick() {
    if (!gameInPlay || selectedSquares.isEmpty) {
      return;
    }
    
    final square = selectedSquares.removeLast();
    final int squareIndex = square.index;
    square.selected = -1;

    wordScoreDisplayText.removeLast();
    String word = wordScoreDisplayText.join('');

    // Update UI immediately
    setState(() {
      displayText = word;
      selected[squareIndex] = false;
    });
    
    // Validate with cached method
    _validateWord(word);
  }

  void handleGameOverButtonClick() {
    resetGame();
  }

  void handleInstClick() {
    setState(() {
      if (instPopupShow) {
        instPopupShow = false;
        if (instPopupShowDuringGamePlay) {
          instPopupShowDuringGamePlay = false;
          resumeGame();
        }
      } else {
        if (gameInPlay) {
          pauseGame();
          instPopupShowDuringGamePlay = true;
        } else {
          instPopupShowDuringGamePlay = false;
        }
        
        instPopupShow = true;
        statPopupShow = false;
      }
    });
  }

  void handleStatClick() {
    setState(() {
      if (statPopupShow) {
        statPopupShow = false;
        if (statPopupShowDuringGamePlay) {
          statPopupShowDuringGamePlay = false;
          resumeGame();
        }
      } else {
        if (gameInPlay) {
          pauseGame();
          statPopupShowDuringGamePlay = true;
        } else {
          statPopupShowDuringGamePlay = false;
        }
        
        statPopupShow = true;
        instPopupShow = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate grid item size based on available height and width
            // This ensures optimal use of space
            final cellSize = constraints.maxWidth / gridWidth;
            
            // Only generate grid items when needed (performance optimization)
            final gridItems = List.generate(totalSquares, (index) {
              return GameSquare(
                key: ValueKey('square_$index'),
                letter: letters[index],
                selected: selected[index],
                onTap: () => handleSquareClick(index),
              );
            });
            
            return Stack(
              children: [
                Column(
                  children: [
                    // Top container
                    Container(
                      height: 50,
                      color: Colors.grey[600],
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InfoButton(onPressed: handleInstClick),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                "Lettris",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: StatsButton(onPressed: handleStatClick),
                          ),
                        ],
                      ),
                    ),
                    
                    // Game grid
                    Expanded(
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(4),
                        crossAxisCount: gridWidth,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        children: gridItems,
                      ),
                    ),
                    
                    // Bottom container
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: StartButton(
                              gameInPlay: gameInPlay,
                              onPressed: handleStartButtonClick,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: double.infinity,
                              child: WordScoreDisplay(
                                displayText: displayText,
                                displayClickable: displayClickable,
                                onTap: handleDisplayClick,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: GameBackButton(
                              onPressed: handleBackButtonClick,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Popups
                if (gameOver)
                  Center(
                    child: GameOverPopup(
                      score: score,
                      highScore: highScore,
                      onOkPressed: handleGameOverButtonClick,
                    ),
                  ),
                
                if (instPopupShow)
                  Center(
                    child: Dialog(
                      child: IntrinsicHeight(
                        child: IntrinsicWidth(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: Column(
                              children: [
                                const Expanded(
                                  child: InstructionsPopup(),
                                ),
                                TextButton(
                                  onPressed: handleInstClick,
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                if (statPopupShow)
                  Center(
                    child: Dialog(
                      child: IntrinsicHeight(
                        child: IntrinsicWidth(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight: MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: StatsPopup(
                                    score: score,
                                    highScore: highScore,
                                  ),
                                ),
                                TextButton(
                                  onPressed: handleStatClick,
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
