import 'package:flutter_test/flutter_test.dart';
import 'package:lettris/utils/dictionary/word_dictionary.dart';
import 'package:lettris/utils/dictionary/dictionary_loader.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Set up sqflite for testing
  setUpAll(() {
    // Initialize sqflite_ffi
    sqfliteFfiInit();
    // Change the default factory for testing
    databaseFactory = databaseFactoryFfi;
  });
  
  group('WordDictionary Tests', () {
    late Database db;
    
    setUp(() async {
      // Create a database in memory for testing
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE words(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT UNIQUE,
              is_valid INTEGER NOT NULL DEFAULT 1,
              frequency INTEGER NOT NULL DEFAULT 0,
              source TEXT
            )
          ''');
          
          await db.execute('CREATE INDEX idx_word ON words(word)');
        }
      );
      
      // Insert some test words
      await db.insert('words', {
        'word': 'CAT', 
        'is_valid': 1, 
        'frequency': 10,
        'source': 'test'
      });
      
      await db.insert('words', {
        'word': 'DOG', 
        'is_valid': 1, 
        'frequency': 5,
        'source': 'test'
      });
      
      await db.insert('words', {
        'word': 'INVALID', 
        'is_valid': 0, 
        'frequency': 0,
        'source': 'test'
      });
    });
    
    tearDown(() async {
      await db.close();
    });
    
    test('WordDictionary is a singleton', () {
      final dict1 = WordDictionary();
      final dict2 = WordDictionary();
      
      expect(identical(dict1, dict2), isTrue);
    });
    
    test('Basic validation works correctly', () {
      final validator = DictionaryLoader();
      
      // Test valid words
      expect(validator._basicWordValidation('CAT'), isTrue);
      expect(validator._basicWordValidation('DOG'), isTrue);
      expect(validator._basicWordValidation('HOUSE'), isTrue);
      
      // Test invalid words
      expect(validator._basicWordValidation('QT'), isFalse); // Too short
      expect(validator._basicWordValidation('XYZPTLK'), isFalse); // No vowels
      expect(validator._basicWordValidation('QRTXYZDFG'), isFalse); // Too many consonants
    });
  });
  
  group('Dictionary Integration Tests', () {
    test('Dictionary loader can be created', () {
      final loader = DictionaryLoader();
      expect(loader, isNotNull);
    });
    
    // Mock test for word validation logic
    test('Word validation logic works', () async {
      // Create a minimal implementation to test the validation logic
      final mockLoader = _MockDictionaryLoader();
      
      // Test with valid words
      expect(await mockLoader.isValidWord('CAT'), isTrue);
      expect(await mockLoader.isValidWord('DOG'), isTrue);
      
      // Test with invalid words
      expect(await mockLoader.isValidWord('XYZ'), isFalse);
      expect(await mockLoader.isValidWord('QT'), isFalse); // Too short
    });
  });
}

// Create a mock implementation of DictionaryLoader for testing
class _MockDictionaryLoader extends DictionaryLoader {
  final Map<String, bool> _mockDictionary = {
    'CAT': true,
    'DOG': true,
    'HOUSE': true,
    'GAME': true,
  };
  
  @override
  Future<bool> isValidWord(String word) async {
    if (word.length < 3) return false;
    
    final upperWord = word.toUpperCase();
    
    // Check mock dictionary
    if (_mockDictionary.containsKey(upperWord)) {
      return _mockDictionary[upperWord]!;
    }
    
    // Use the basic validation as fallback
    return _basicWordValidation(upperWord);
  }
}
