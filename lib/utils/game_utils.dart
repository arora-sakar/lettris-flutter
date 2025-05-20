import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'dictionary/dictionary_loader.dart';

class Square {
  String alphabet;
  int selected;
  int index;

  Square({this.alphabet = '', this.selected = -1, required this.index});

  Square copyWith({String? alphabet, int? selected, int? index}) {
    return Square(
      alphabet: alphabet ?? this.alphabet,
      selected: selected ?? this.selected,
      index: index ?? this.index,
    );
  }
}

// Singleton instance of DictionaryLoader
final DictionaryLoader _dictionaryLoader = DictionaryLoader.instance;

// Helper function to get a pseudorandom letter with weighted distribution
String getPseudorandomLetter() {
  const String weightedLetters = "EEEEEEEEEEAAAAAAAARRRRRRRIIIIIIIOOOOOOOTTTTTTTNNNNNNNSSSSSSLLLLLCCCCCUUUUDDDPPPMMMHHHGGBBFFYYWKVXZJQ";
  return weightedLetters[Random().nextInt(weightedLetters.length)];
}

// Initialize the dictionary
Future<void> loadDictionary() async {
  try {
    // Initialize the new dictionary system
    await _dictionaryLoader.initialize();
    
    // For backward compatibility, also set the old flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("localWordsV1", true);
    
    if (kDebugMode) {
      print("Dictionary loaded successfully");
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error loading dictionary: $error");
    }
    
    // If new dictionary fails, try old method for fallback
    await _loadLegacyDictionary();
  }
}

// Legacy dictionary loading method (kept for backward compatibility)
Future<void> _loadLegacyDictionary() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Check if dictionary is already loaded
  if (prefs.getBool("localWordsV1") == true) {
    return;
  }
  
  try {
    // Load words.txt from assets
    String data = await rootBundle.loadString('assets/words.txt');
    List<String> tmpList = data.split("\n");
    
    for (String word in tmpList) {
      word = word.replaceAll("\r", "");
      if (prefs.getString(word) == null) {
        await prefs.setString(word, "valid");
      }
    }
    
    await prefs.setBool("localWordsV1", true);
  } catch (error) {
    if (kDebugMode) {
      print("Error loading legacy dictionary: $error");
    }
  }
}

// Check if a word is valid
Future<bool> checkValidWord(String word) async {
  if (word.length < 3) {
    return false;
  }

  // Try the new dictionary first
  try {
    if (_dictionaryLoader.isInitialized) {
      return await _dictionaryLoader.isValidWord(word);
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error with new dictionary, falling back to legacy: $error");
    }
  }
  
  // Fall back to the old method if new dictionary isn't available
  return await _checkWordLegacy(word);
}

// Legacy word validation method (kept for backward compatibility)
Future<bool> _checkWordLegacy(String word) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Check local storage first
  if (prefs.getString(word) == "valid") {
    return true;
  }
  
  // For common English words, allow even without API validation
  if (word.length >= 4 && _isCommonEnglishWord(word)) {
    await prefs.setString(word, "valid");
    return true;
  }
  
  // No API call here - just use local validation for fallback
  if (word.length >= 3 && _isCommonEnglishWord(word)) {
    await prefs.setString(word, "valid");
    return true;
  }
  
  return false;
}

// Basic check for common English words based on patterns
bool _isCommonEnglishWord(String word) {
  // Common word endings
  final List<String> commonEndings = ['ing', 'ed', 's', 'er', 'ly', 'est', 'ment', 'tion', 'ness', 'ful', 'less'];
  
  // Check for common word endings
  for (String ending in commonEndings) {
    if (word.length > ending.length + 2 && word.toLowerCase().endsWith(ending)) {
      return true;
    }
  }
  
  // Vowel-consonant pattern check (simple heuristic for English words)
  if (word.length >= 3) {
    int vowelCount = 0;
    for (int i = 0; i < word.length; i++) {
      if ('AEIOUaeiou'.contains(word[i])) {
        vowelCount++;
      }
    }
    
    // Most English words have at least one vowel per 3 letters
    if (vowelCount >= word.length / 3) {
      return true;
    }
  }
  
  return false;
}

// Track word usage for analytics and improving dictionary
Future<void> trackWordUsage(String word) async {
  if (word.length < 3) return;
  
  try {
    // Normalize the word to uppercase for consistency
    final upperWord = word.toUpperCase();
    
    // Track in the new dictionary system
    if (_dictionaryLoader.isInitialized) {
      await _dictionaryLoader.trackWordUsage(upperWord);
    }
    
    // Also store in recent words list in shared preferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentWords = prefs.getStringList('recentWords') ?? [];
    
    // Check if the word already exists (case-insensitive)
    final bool alreadyExists = recentWords.any(
      (existingWord) => existingWord.toUpperCase() == upperWord
    );
    
    if (!alreadyExists) {
      // Add the word at the beginning of the list (newest first)
      recentWords.insert(0, upperWord);
      
      // Keep list to a reasonable size
      if (recentWords.length > 100) {
        recentWords.removeLast(); // Remove the oldest word at the end
      }
      
      await prefs.setStringList('recentWords', recentWords);
    }
  } catch (error) {
    if (kDebugMode) {
      print("Error tracking word usage: $error");
    }
  }
}

// Get recent words
Future<List<String>> getRecentWords() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('recentWords') ?? [];
}

// Get high score from shared preferences
Future<int> getHighScore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("highScore") ?? 0;
}

// Save high score to shared preferences
Future<void> saveHighScore(int score) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt("highScore", score);
}
