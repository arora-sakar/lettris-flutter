import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// WordDictionary is a singleton class that provides access to the SQLite
/// database containing word data for the game.
class WordDictionary {
  // Singleton instance
  static final WordDictionary _instance = WordDictionary._internal();
  factory WordDictionary() => _instance;
  WordDictionary._internal();
  
  // Database reference
  static Database? _database;
  
  // Version tracking
  static const String kDatabaseName = 'lettris_dictionary.db';
  static const int kDatabaseVersion = 1;
  
  // Table and column names
  static const String tableWords = 'words';
  static const String colId = 'id';
  static const String colWord = 'word';
  static const String colIsValid = 'is_valid';
  static const String colFrequency = 'frequency';
  static const String colSource = 'source';
  
  /// Get the database instance. Creates it if it doesn't exist.
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Get the documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, kDatabaseName);
    
    if (kDebugMode) {
      print('Initializing database at $path');
    }
    
    // Open the database
    return await openDatabase(
      path,
      version: kDatabaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) {
      print('Creating new database at version $version');
    }
    
    // Create words table
    await db.execute('''
      CREATE TABLE $tableWords(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colWord TEXT UNIQUE,
        $colIsValid INTEGER NOT NULL DEFAULT 1,
        $colFrequency INTEGER NOT NULL DEFAULT 0,
        $colSource TEXT
      )
    ''');
    
    // Create index on word column for faster lookups
    await db.execute('CREATE INDEX idx_word ON $tableWords($colWord)');
  }
  
  /// Handle database version upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('Upgrading database from version $oldVersion to $newVersion');
    }
    
    // In the future, add migration logic here
    if (oldVersion < 2) {
      // Example: Add new columns or tables for version 2
    }
  }
  
  /// Check if a word exists in the database
  Future<bool> wordExists(String word) async {
    final db = await database;
    final result = await db.query(
      tableWords,
      where: '$colWord = ?',
      whereArgs: [word.toUpperCase()],
      limit: 1,
    );
    
    return result.isNotEmpty;
  }
  
  /// Check if a word is valid
  Future<bool> isValidWord(String word) async {
    final db = await database;
    final result = await db.query(
      tableWords,
      columns: [colIsValid],
      where: '$colWord = ?',
      whereArgs: [word.toUpperCase()],
      limit: 1,
    );
    
    if (result.isEmpty) {
      return false;
    }
    
    return result.first[colIsValid] == 1;
  }
  
  /// Insert a word into the database
  Future<int> insertWord(String word, {bool isValid = true, int frequency = 0, String source = 'core'}) async {
    final db = await database;
    final wordUpper = word.toUpperCase();
    
    return await db.insert(
      tableWords,
      {
        colWord: wordUpper,
        colIsValid: isValid ? 1 : 0,
        colFrequency: frequency,
        colSource: source,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Insert multiple words in a batch operation
  Future<void> insertWords(List<String> words, {bool isValid = true, int frequency = 0, String source = 'core'}) async {
    final db = await database;
    final batch = db.batch();
    
    for (final word in words) {
      final wordUpper = word.toUpperCase().trim();
      if (wordUpper.isNotEmpty) {
        batch.insert(
          tableWords,
          {
            colWord: wordUpper,
            colIsValid: isValid ? 1 : 0,
            colFrequency: frequency,
            colSource: source,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }
  
  /// Update word frequency
  Future<int> updateWordFrequency(String word, int frequency) async {
    final db = await database;
    return await db.update(
      tableWords,
      {colFrequency: frequency},
      where: '$colWord = ?',
      whereArgs: [word.toUpperCase()],
    );
  }
  
  /// Increment word frequency
  Future<void> incrementWordFrequency(String word) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $tableWords SET $colFrequency = $colFrequency + 1 WHERE $colWord = ?',
      [word.toUpperCase()],
    );
  }
  
  /// Get the count of words in the database
  Future<int> getWordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableWords');
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Prepare a batch operation
  Future<Batch> prepareBatch() async {
    final db = await database;
    return db.batch();
  }
  
  /// Commit a batch operation
  Future<List<Object?>> commitBatch(Batch batch) async {
    return await batch.commit();
  }
  
  /// Get all words from the database (use cautiously with large dictionaries)
  Future<List<Map<String, dynamic>>> getAllWords({int limit = 100}) async {
    final db = await database;
    return await db.query(
      tableWords,
      orderBy: '$colFrequency DESC',
      limit: limit,
    );
  }
  
  /// Delete the database
  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, kDatabaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
