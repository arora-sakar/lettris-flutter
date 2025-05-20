import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'word_dictionary.dart';

/// DictionaryLoader is responsible for loading and managing the word dictionary
/// It provides an interface for the game to check word validity and other
/// dictionary-related operations.
class DictionaryLoader {
  // Singleton instance
  static final DictionaryLoader _instance = DictionaryLoader._internal();
  static DictionaryLoader get instance => _instance;
  factory DictionaryLoader() => _instance;
  DictionaryLoader._internal();
  
  // Database access
  final WordDictionary _dictionary = WordDictionary();
  
  // In-memory cache for word validation results
  final Map<String, bool> _validationCache = {};
  
  // Initialization state
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Version tracking for preferences
  static const String kDictionaryVersionKey = 'dictionary_version';
  static const String kCoreLoadedKey = 'core_dictionary_loaded';
  static const int kDictionaryVersion = 2; // Incremented to force reload
  
  /// Initialize the dictionary
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(kDictionaryVersionKey) ?? 0;
      final coreLoaded = prefs.getBool(kCoreLoadedKey) ?? false;
      
      if (version < kDictionaryVersion || !coreLoaded) {
        // Clear existing dictionary if version changed
        if (version < kDictionaryVersion && version > 0) {
          await _dictionary.deleteDatabase();
        }
        
        // Load core dictionary from assets
        await _loadCoreDictionary();
        
        // Update preferences
        await prefs.setInt(kDictionaryVersionKey, kDictionaryVersion);
        await prefs.setBool(kCoreLoadedKey, true);
      }
      
      _isInitialized = true;
      
      // Log dictionary stats in debug mode
      if (kDebugMode) {
        final count = await _dictionary.getWordCount();
        print('Dictionary initialized with $count words');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing dictionary: $e');
      }
      
      // Reset initialization state to allow retrying
      _isInitialized = false;
      rethrow;
    }
  }
  
  /// Load the core dictionary from assets
  Future<void> _loadCoreDictionary() async {
    try {
      if (kDebugMode) {
        print('Loading core dictionary from assets');
      }
      
      // Load words.txt from assets
      final String data = await rootBundle.loadString('assets/words.txt');
      final List<String> words = data.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.isNotEmpty)
          .toList();
      
      if (kDebugMode) {
        print('Loaded ${words.length} words from assets');
      }
      
      // Process in batches for better performance
      const int batchSize = 500;
      for (int i = 0; i < words.length; i += batchSize) {
        final int end = (i + batchSize < words.length) ? i + batchSize : words.length;
        final batch = words.sublist(i, end);
        
        await _dictionary.insertWords(
          batch,
          isValid: true,
          frequency: 10, // Default frequency for core words
          source: 'core',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading core dictionary: $e');
      }
      rethrow;
    }
  }
  
  /// Check if a word is valid
  Future<bool> isValidWord(String word) async {
    if (word.length < 3) return false;
    
    final upperWord = word.toUpperCase();
    
    // Check in-memory cache first (fast)
    if (_validationCache.containsKey(upperWord)) {
      return _validationCache[upperWord]!;
    }
    
    try {
      // Check in database
      final isValid = await _dictionary.isValidWord(upperWord);
      if (isValid) {
        // Cache the result
        _validationCache[upperWord] = true;
        return true;
      }
      
      // Optional: If not found in database, check online API
      // This can be implemented later
      
      // Not valid
      _validationCache[upperWord] = false;
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking word validity: $e');
      }
      
      // Fallback validation in case of database error
      final isValid = _basicWordValidation(upperWord);
      _validationCache[upperWord] = isValid;
      return isValid;
    }
  }
  
  /// Add a word to the dictionary
  Future<void> addWord(String word, {bool isValid = true, int frequency = 5, String source = 'user'}) async {
    final upperWord = word.toUpperCase();
    await _dictionary.insertWord(
      upperWord,
      isValid: isValid,
      frequency: frequency,
      source: source,
    );
    
    // Update cache
    _validationCache[upperWord] = isValid;
  }
  
  /// Track word usage
  Future<void> trackWordUsage(String word) async {
    if (word.length < 3) return;
    
    try {
      final upperWord = word.toUpperCase();
      await _dictionary.incrementWordFrequency(upperWord);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking word usage: $e');
      }
    }
  }
  
  /// Clear validation cache
  void clearCache() {
    _validationCache.clear();
  }
  
  /// Reset dictionary completely
  Future<void> resetDictionary() async {
    try {
      // Delete the database
      await _dictionary.deleteDatabase();
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kDictionaryVersionKey);
      await prefs.remove(kCoreLoadedKey);
      
      // Clear cache
      _validationCache.clear();
      
      // Reset initialization state
      _isInitialized = false;
      
      if (kDebugMode) {
        print('Dictionary has been reset');
      }
      
      // Re-initialize
      await initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting dictionary: $e');
      }
      rethrow;
    }
  }
  
  /// Basic word validation as fallback
  bool _basicWordValidation(String word) {
    if (word.length < 3) return false;
    
    // Check if the word has vowels (basic rule for English words)
    final hasVowel = word.contains(RegExp(r'[AEIOU]'));
    if (!hasVowel) return false;
    
    // Count consonants in a row
    int consonantCount = 0;
    int maxConsonants = 0;
    
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if ('AEIOU'.contains(char)) {
        consonantCount = 0;
      } else {
        consonantCount++;
        if (consonantCount > maxConsonants) {
          maxConsonants = consonantCount;
        }
      }
    }
    
    // Too many consonants in a row is unlikely in English
    if (maxConsonants > 4) return false;
    
    // Common word endings for English
    if (word.length > 4) {
      final bool hasCommonEnding = [
        'ING', 'ED', 'S', 'ER', 'LY', 'EST', 'MENT', 'TION', 'NESS', 'FUL', 'LESS'
      ].any((ending) => word.endsWith(ending));
      
      if (hasCommonEnding) return true;
    }
    
    // For 3-4 letter words, be more permissive
    if (word.length <= 4) return true;
    
    // Default to false for longer words without common patterns
    return false;
  }
}
