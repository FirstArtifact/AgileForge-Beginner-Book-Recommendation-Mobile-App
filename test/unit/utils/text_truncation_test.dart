import 'package:flutter_test/flutter_test.dart';
import 'package:book_recommendation_app/utils/text_utils.dart';

void main() {
  group('truncateText', () {
    test('returns original string when length equals maxLength', () {
      final text = 'Hello'; // length 5
      final result = truncateText(text, 5);
      expect(result, equals('Hello'));
    });

    test('returns original string when length is less than maxLength', () {
      final text = 'Hi'; // length 2
      final result = truncateText(text, 10);
      expect(result, equals('Hi'));
    });

    test('truncates string exceeding maxLength and appends ellipsis', () {
      final text = 'Hello, World!'; // length 13
      final result = truncateText(text, 5);
      expect(result, equals('Hello...'));
      expect(result.length, equals(5 + 3)); // maxLength + "..."
    });

    test('returns empty string unchanged when maxLength is 0 or more', () {
      final result = truncateText('', 10);
      expect(result, equals(''));
    });

    test('truncates at N=50 for book titles', () {
      final longTitle = 'A' * 60; // 60 chars, exceeds 50
      final result = truncateText(longTitle, 50);
      expect(result.length, equals(53)); // 50 + 3
      expect(result.endsWith('...'), isTrue);
      expect(result.substring(0, 50), equals('A' * 50));
    });

    test('does not truncate title at exactly 50 characters', () {
      final exactTitle = 'B' * 50; // exactly 50 chars
      final result = truncateText(exactTitle, 50);
      expect(result, equals(exactTitle));
      expect(result.length, equals(50));
    });

    test('truncates at N=500 for book descriptions', () {
      final longDescription = 'C' * 510; // 510 chars, exceeds 500
      final result = truncateText(longDescription, 500);
      expect(result.length, equals(503)); // 500 + 3
      expect(result.endsWith('...'), isTrue);
      expect(result.substring(0, 500), equals('C' * 500));
    });

    test('does not truncate description at exactly 500 characters', () {
      final exactDescription = 'D' * 500; // exactly 500 chars
      final result = truncateText(exactDescription, 500);
      expect(result, equals(exactDescription));
      expect(result.length, equals(500));
    });

    test('truncated result ends with "..."', () {
      final text = 'This is a long sentence that should be truncated';
      final result = truncateText(text, 10);
      expect(result.endsWith('...'), isTrue);
    });

    test('truncated result has exactly maxLength + 3 characters', () {
      final text = 'abcdefghijklmnopqrstuvwxyz'; // 26 chars
      final result = truncateText(text, 10);
      expect(result.length, equals(13)); // 10 + 3
    });
  });
}
