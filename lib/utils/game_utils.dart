import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

const String localWordsVersion = "localWordsV1";

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

// Helper function to get a pseudorandom letter with weighted distribution
String getPseudorandomLetter() {
  const String weightedLetters = "EEEEEEEEEEAAAAAAAARRRRRRRIIIIIIIOOOOOOOTTTTTTTNNNNNNNSSSSSSLLLLLCCCCCUUUUDDDPPPMMMHHHGGBBFFYYWKVXZJQ";
  return weightedLetters[Random().nextInt(weightedLetters.length)];
}

// Fetch words from assets/words.txt and store in local storage
Future<void> loadDictionary() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Check if dictionary is already loaded
  if (prefs.getBool(localWordsVersion) == true) {
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
    
    await prefs.setBool(localWordsVersion, true);
  } catch (error) {
    print("Error loading dictionary: $error");
  }
}

// Check if a word is valid
Future<bool> checkValidWord(String word) async {
  if (word.length < 3) {
    return false;
  }

  final prefs = await SharedPreferences.getInstance();
  
  // Check local storage first
  if (prefs.getString(word) == "valid") {
    return true;
  }
  
  // For common English words, allow even without API validation
  if (word.length >= 4 && isCommonEnglishWord(word)) {
    await prefs.setString(word, "valid");
    return true;
  }
  
  try {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word')
    ).timeout(const Duration(seconds: 3)); // Add timeout
    
    if (response.statusCode == 200) {
      await prefs.setString(word, "valid");
      return true;
    }
  } catch (error) {
    print("Error checking word: $error");
    
    // Fallback validation for when API is unreachable
    if (word.length >= 3 && isCommonEnglishWord(word)) {
      await prefs.setString(word, "valid");
      return true;
    }
  }
  
  return false;
}

// Basic check for common English words based on patterns
bool isCommonEnglishWord(String word) {
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
