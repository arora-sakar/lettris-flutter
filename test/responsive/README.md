# Responsive UI Tests

This directory contains tests that verify the Lettris game UI behaves properly on different screen sizes and orientations.

## What These Tests Verify

1. **Adaptability**: Tests ensure UI layouts properly adapt to:
   - Small screens (phone sized)
   - Large screens (tablet sized)
   - Landscape orientation

2. **Accessibility**: Tests verify that:
   - Interactive elements (buttons, tappable areas) meet minimum touch target size requirements (48x48 pixels)
   - Text is readable on different screen sizes
   - All UI elements remain fully visible and usable across screen sizes

3. **No Overflow Errors**: Tests confirm no layout overflow errors occur when:
   - Changing screen orientation
   - Viewing on small screens
   - Viewing on large screens

## Running the Tests

```bash
# Run all responsive tests
flutter test test/responsive/

# Run a specific test file
flutter test test/responsive/responsive_layout_test.dart
```

## Key Design Principles

1. **Minimum Touch Target Size**: All interactive elements should be at least 48x48 pixels for proper touch accessibility.
2. **Adaptive Layout**: UI should adapt to different screen sizes using Expanded widgets, Flex layouts, etc.
3. **Orientation Support**: Game should be playable in both portrait and landscape modes.
4. **Text Scaling**: Text should remain readable across device sizes.
