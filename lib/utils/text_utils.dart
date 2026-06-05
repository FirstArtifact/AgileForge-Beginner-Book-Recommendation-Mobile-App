/// Utility functions for text manipulation in the Book Recommendation App.
///
/// Used to truncate book titles (N=50) and descriptions (N=500) for display
/// in list views and detail screens.
library;

/// Truncates [text] to [maxLength] characters, appending "..." if truncated.
///
/// Returns the original string unchanged if its length is ≤ [maxLength].
/// Returns a string of exactly [maxLength] + 3 characters (first [maxLength]
/// characters followed by "...") if the original exceeds [maxLength].
///
/// Example:
/// ```dart
/// truncateText('Hello, World!', 5); // Returns 'Hello...'
/// truncateText('Hi', 5);           // Returns 'Hi'
/// ```
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength)}...';
}
