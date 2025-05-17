# Lettris - A Word Puzzle Game

Lettris is a Flutter-based mobile game that combines elements of Tetris and word formation games. Players aim to create words from falling letter tiles to score points and prevent the grid from filling up.

## 🌟 Features

* **Classic Gameplay, Modern Twist:** Enjoy the familiar challenge of falling blocks, but with letters!
* **Word Formation:** Select adjacent letters on the grid to form words of 3 letters or more.
* **Scoring System:** Longer words yield more points. Beat your high score!
* **Responsive Design:** Adapts to both portrait and landscape orientations for comfortable gameplay.
* **Local Dictionary:** Utilizes a local dictionary for fast word validation, with an online API fallback.
* **Persistent High Score:** Your best score is saved locally.
* **In-Game Instructions & Stats:** Easily accessible information about how to play and your current/high scores.

## 🎮 How to Play

1.  **Start the Game:** Press the "START" button to begin the game. Letter tiles will start falling from the top.
2.  **Form Words:** Tap on adjacent letter tiles (horizontally, vertically, or diagonally) to select them and form a word. The selected word appears in the display area.
3.  **Submit Words:** Once a valid word of 3 or more letters is formed, the word display area becomes clickable. Tap it to submit the word, clear the selected tiles from the grid, and earn points.
4.  **Clear Tiles:** Submitted letters are removed, and any tiles above them will fall down.
5.  **Game Over:** The game ends if any column of letter tiles reaches the top of the grid.
6.  **Controls:**
    * **START/PAUSE:** Toggles the game state.
    * **BACK:** Removes the last selected letter from the current word.
    * **Word Display:** Shows the currently selected letters. Becomes clickable when a valid word is formed.
    * **Info Button (i):** Shows the "How to Play" instructions.
    * **Stats Button (...):** Shows your current score and high score.

## 📂 Project Structure

The project is organized into the following main directories within the `lib` folder:

* `main.dart`: The entry point of the application, sets up the app and routes.
* `screens/`: Contains the widget definitions for the different screens of the app (e.g., `home_screen.dart`, `lettris_screen.dart`).
* `widgets/`: Contains reusable UI components used across different screens (e.g., `game_widgets.dart` for game-specific UI elements like the game grid, buttons, popups).
* `utils/`: Contains utility functions and classes (e.g., `game_utils.dart` for game logic helpers, dictionary management, high score persistence).
* `assets/`:
    * `words.txt`: A list of valid words used for the local dictionary.

## 🛠️ Setup and Installation

To run this project locally:

1.  **Prerequisites:**
    * Ensure you have Flutter SDK installed.
    * An editor like VS Code or Android Studio with the Flutter plugin.
    * A device (emulator or physical) to run the app.

2.  **Clone the Repository (if applicable):**
    ```bash
    git clone <your-repository-url>
    cd lettris-project
    ```

3.  **Get Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

## 🚀 Potential Future Improvements

Based on the current codebase, here are some areas for future enhancements (refer to the detailed code analysis for more):

* **Advanced State Management:** Implement a more robust state management solution (like Provider, Riverpod, or BLoC/Cubit) for `lettris_screen.dart` to better handle complex game state.
* **Enhanced Theming:** Define a more comprehensive color scheme and use theme colors consistently throughout the widgets.
* **Improved Error Handling:** Implement more user-friendly error messages, especially for API failures.
* **Animations & Sound Effects:** Add animations for tile movements, scoring, and game events. Incorporate sound effects for a more engaging experience.
* **Difficulty Levels:** Introduce different difficulty settings (e.g., faster falling speed, different letter distributions).
* **More Robust Word Validation:** Refine the `isCommonEnglishWord` heuristic or explore more comprehensive offline dictionary solutions.
* **Code Refinements:**
    * Address DRY principles (e.g., centralize `_getResponsiveFontSize`).
    * Further break down complex widgets and methods.
    * Improve test coverage with more unit and widget tests.

## 🙏 Acknowledgements

* This game uses an external API for word validation: [DictionaryAPI.dev](https://dictionaryapi.dev/)

---

*This README was generated based on the project's Dart files.*