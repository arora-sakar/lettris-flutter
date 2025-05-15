# Lettris Game - Comprehensive Test Suite

This directory contains a complete test suite for the Lettris game application. The tests are organized into different categories to ensure thorough coverage of all aspects of the game.

## Test Structure

```
test/
├── widget_test.dart                          # Main entry point for all tests
├── unit/                                     # Tests for isolated functions and classes
│   ├── game_utils_test.dart                  # Basic unit tests
│   └── game_utils_advanced_test.dart         # Edge cases and performance tests
├── widget/                                   # Tests for UI components
│   ├── game_widgets_test.dart                # Basic widget tests
│   ├── game_widgets_advanced_test.dart       # Advanced widget scenarios
│   ├── home_screen_test.dart                 # Home screen tests
│   ├── lettris_screen_test.dart              # Game screen tests
│   └── lettris_screen_advanced_test.dart     # Edge cases for game screen
├── integration/                              # End-to-end tests
│   └── lettris_game_test.dart                # Full gameplay tests
├── responsive/                               # Tests for responsive design
│   └── responsive_design_test.dart           # Tests across different screen sizes
├── golden/                                   # Visual regression tests
│   └── ui_golden_test.dart                   # Golden image comparisons
├── benchmark/                                # Performance testing
│   ├── performance_benchmark_test.dart       # Performance measurements
│   └── resource_management_test.dart         # Memory and resource tests
└── accessibility/                            # Accessibility compliance tests
    └── accessibility_test.dart               # Tests for accessibility features
```

## Setup

Before running the tests, make sure to install the dependencies:

```bash
flutter pub get
```

If you're using mock-based tests, you'll need to generate the mock implementations:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running Tests

### Running All Tests

To run all tests (except golden and benchmark tests, which are excluded by default):

```bash
flutter test
```

### Running Specific Test Categories

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/

# Responsive design tests
flutter test test/responsive/

# Accessibility tests
flutter test test/accessibility/
```

### Running Golden Tests

Golden tests compare the current UI against saved "golden" images. These tests are sensitive to pixel-level differences and may fail with minor UI changes.

```bash
flutter test test/golden/
```

If the UI has intentionally changed, you can update the golden files:

```bash
flutter test --update-goldens test/golden/
```

### Running Benchmark Tests

Benchmark tests measure performance aspects of the application. These tests may take longer to run.

```bash
flutter test test/benchmark/
```

## Troubleshooting

### Mock-related Errors

If you encounter errors related to missing mock classes (e.g., `MockClient`), make sure to run the code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Golden Test Failures

Golden test failures are expected when the UI changes. Update the golden files with:

```bash
flutter test --update-goldens test/golden/
```

### Slow or Failing Performance Tests

Performance tests have conservative thresholds by default. If they're failing on your machine, consider adjusting the thresholds in the test files to match your hardware capabilities.

## Test Coverage

### Unit Tests

Tests for game utilities and core logic:
- Square class functionality
- Letter generation and distribution
- Word validation logic
- High score management
- Edge cases and performance aspects

### Widget Tests

Tests for UI components and screens:
- Game squares, buttons, and displays
- Screen initialization and state management
- User interactions and gameplay mechanics
- Edge cases like long words and rapid inputs

### Integration Tests

End-to-end tests for the complete application:
- Full gameplay flow
- Game over handling
- Word selection and submission
- Score calculation

### Responsive Design Tests

Tests for adaptive layouts across different devices:
- Portrait and landscape orientations
- Phone and tablet screen sizes
- Dynamic text and UI element scaling

### Golden Tests

Visual regression tests to ensure UI consistency:
- Screen layouts and components
- Different states (selected, clickable, etc.)
- Popups and dialog appearances

### Benchmark Tests

Performance monitoring tests:
- Rendering performance
- Game state update speed
- Word validation efficiency
- Memory usage patterns

### Accessibility Tests

Tests for accessibility compliance:
- Text contrast
- Touch target sizes
- Text scaling support
- Screen reader compatibility (basic)

## Best Practices for Test Maintenance

1. **Update Golden Tests**: When making intentional UI changes, remember to update golden images.

2. **Adjust Benchmark Thresholds**: Performance expectations may need adjustment based on the test environment.

3. **Test New Features**: Add corresponding tests for any new features or changed functionality.

4. **Isolate Flaky Tests**: If a test is inconsistent, isolate it with `testWidgets(..., skip: true)` until fixed.

5. **Mock Dependencies**: External dependencies like `SharedPreferences` should always be mocked.

## Running Tests in CI/CD

The test suite is designed to run in CI/CD environments. For CI integration:

1. Normal tests run in the standard Flutter test environment
2. Golden tests should be run on consistent hardware/environments to avoid false failures
3. Benchmark tests should be used for information, not for pass/fail in CI

Example GitHub Actions workflow is included in `.github/workflows/flutter_ci.yml`.
