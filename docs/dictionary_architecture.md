# Dictionary Architecture

This document provides an overview of the dictionary architecture used in the Lettris Flutter game, including the current implementation and design decisions.

## Current Architecture

### Components

1. **WordDictionary**
   - Core SQLite database management
   - Word storage and retrieval
   - Database schema and indexing
   - CRUD operations for words

2. **DictionaryLoader**
   - Dictionary initialization and loading
   - Word validation logic
   - In-memory caching for performance
   - Fallback validation methods

3. **Game Integration**
   - Word tracking through game mechanics
   - Recent words tracking and display
   - Dictionary reset functionality
   - Performance optimizations for gameplay

### Data Flow

```
┌────────────────┐     ┌─────────────────┐     ┌────────────────┐
│                │     │                 │     │                │
│  Game Logic    │────▶│  DictionaryLoader│────▶│  WordDictionary │
│                │     │                 │     │                │
└────────────────┘     └─────────────────┘     └────────────────┘
        │                      │                      │
        │                      │                      │
        ▼                      ▼                      ▼
┌────────────────┐     ┌─────────────────┐     ┌────────────────┐
│                │     │                 │     │                │
│    UI Layer    │     │  Memory Cache   │     │  SQLite DB     │
│                │     │                 │     │                │
└────────────────┘     └─────────────────┘     └────────────────┘
```

## Design Decisions

### SQLite vs SharedPreferences
The system uses SQLite for dictionary storage instead of SharedPreferences for several reasons:
- Better performance for large datasets
- Support for complex queries and indices
- Reduced memory footprint
- Structured data storage with relationships

### Multi-tier Word Validation
Word validation happens in the following order:
1. In-memory cache (fastest)
2. SQLite database lookup (fast)
3. Basic pattern validation (fallback)
4. Online API validation (optional, not currently implemented)

### Case Handling
All words are normalized to uppercase for consistency in:
- Storage
- Validation
- Display
- Comparison operations

### Dictionary Versioning
The system includes version tracking to:
- Manage dictionary updates
- Trigger reloads when needed
- Support backward compatibility
- Enable incremental updates

## Potential Improvements

### Performance Optimizations
- Implement prepared statements for common queries
- Use transaction batching for bulk operations
- Create optimized indices for specific query patterns
- Consider memory-mapped database access

### Scalability
- Implement sharding for very large dictionaries
- Create modular dictionary components
- Support for pluggable dictionary sources
- Dynamic loading/unloading of dictionary segments

### Enhanced Features
- Word frequency statistics
- Semantic word relationships
- Word categorization and tagging
- Multi-language support

## Technical Considerations

### Memory Management
- Dictionary cache size limits
- Lazy loading strategies
- Eviction policies for cached words
- Monitoring and debugging tools

### Threading and Concurrency
- Background loading processes
- Non-blocking validation
- Thread-safe database access
- UI responsiveness during dictionary operations

### Error Handling
- Graceful degradation for database failures
- Recovery mechanisms
- Consistent error reporting
- User feedback for critical failures
