# README

## Lettris Flutter

A word game combining letter tiles and strategy, built with Flutter.

![Lettris Game](assets/game_screenshot.png)

## Description

Lettris is a word-forming game where letters fall from the top of the screen in a Tetris-like fashion. Players must form valid English words to clear letters from the screen before they stack up to the top.

## Features

- Responsive design that works on both phones and tablets, in portrait and landscape orientations
- Smooth gameplay with falling letter animations
- Valid word detection with offline dictionary
- Score tracking with high score persistence
- Recent words tracking to see your word history
- Pause/resume functionality
- Game over detection and reset

## Technical Implementation

The game is implemented with several key components:

### Game Engine

- Custom-built game logic with optimized state management
- Efficient collision detection and letter falling mechanics
- Pseudo-random letter generation with English-like frequency distribution

### Dictionary System

- SQLite-based dictionary for fast word lookup
- Multi-tiered validation approach with in-memory caching
- Support for custom dictionary expansion
- Word tracking for player statistics

### UI Components

- Custom widget implementations for game elements
- Responsive design that adapts to different screen sizes and orientations
- Accessibility considerations in UI design

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio, VS Code, or other Flutter-compatible IDE

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/lettris-flutter.git
   ```

2. Navigate to the project directory:
   ```
   cd lettris-flutter
   ```

3. Get dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## How to Play

1. Press START to begin the game
2. Tap falling letters to form words
3. When a valid word is formed (3+ letters), the word display turns grey and becomes clickable
4. Tap the word display to clear those letters and score points
5. Use BACK to remove the last letter if needed
6. The game ends when the letters stack to the top of the screen

## Project Structure

The project follows a clean architecture:

- `lib/screens/` - Game screens and UI
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Game utilities and logic
- `lib/utils/dictionary/` - Dictionary implementation
- `test/` - Comprehensive test suite

## Testing

The project includes various types of tests:

- Unit tests for core game logic
- Widget tests for UI components
- Integration tests for full game flows
- Performance benchmarks for optimization
- Accessibility tests for inclusive design

Run tests with:
```
flutter test
```

## Future Development

See the [Dictionary Upgrade Roadmap](docs/dictionary_upgrade_roadmap.md) for upcoming features and improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Tetris and word game classics for inspiration
- Open source dictionary resources
