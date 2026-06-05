import 'dart:convert';

import 'package:book_recommendation_app/services/favorites_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesService', () {
    late FavoritesService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = FavoritesService();
    });

    group('getFavoriteIds', () {
      test('returns empty list when no favorites exist', () async {
        final result = await service.getFavoriteIds();
        expect(result, isEmpty);
      });

      test('returns stored favorites from shared_preferences', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_book_ids': jsonEncode(['book-1', 'book-2', 'book-3']),
        });
        service = FavoritesService();

        final result = await service.getFavoriteIds();
        expect(result, ['book-1', 'book-2', 'book-3']);
      });

      test('returns unmodifiable list', () async {
        await service.addFavorite('book-1');
        final result = await service.getFavoriteIds();
        expect(() => (result as List).add('book-2'), throwsA(isA<Error>()));
      });
    });

    group('addFavorite', () {
      test('adds a book ID to favorites', () async {
        await service.addFavorite('book-1');

        final result = await service.getFavoriteIds();
        expect(result, contains('book-1'));
      });

      test('adds new favorites to the front of the list (most recent first)',
          () async {
        await service.addFavorite('book-1');
        await service.addFavorite('book-2');
        await service.addFavorite('book-3');

        final result = await service.getFavoriteIds();
        expect(result, ['book-3', 'book-2', 'book-1']);
      });

      test('does not duplicate an already-favorited book', () async {
        await service.addFavorite('book-1');
        await service.addFavorite('book-1');

        final result = await service.getFavoriteIds();
        expect(result.length, 1);
        expect(result, ['book-1']);
      });

      test('persists to shared_preferences', () async {
        await service.addFavorite('book-1');
        await service.addFavorite('book-2');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('favorite_book_ids');
        expect(stored, isNotNull);

        final decoded = jsonDecode(stored!) as List;
        expect(decoded, ['book-2', 'book-1']);
      });
    });

    group('removeFavorite', () {
      test('removes a book ID from favorites', () async {
        await service.addFavorite('book-1');
        await service.addFavorite('book-2');

        await service.removeFavorite('book-1');

        final result = await service.getFavoriteIds();
        expect(result, ['book-2']);
      });

      test('does nothing when removing a non-existent favorite', () async {
        await service.addFavorite('book-1');
        await service.removeFavorite('book-99');

        final result = await service.getFavoriteIds();
        expect(result, ['book-1']);
      });

      test('persists removal to shared_preferences', () async {
        await service.addFavorite('book-1');
        await service.addFavorite('book-2');
        await service.removeFavorite('book-1');

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString('favorite_book_ids');
        final decoded = jsonDecode(stored!) as List;
        expect(decoded, ['book-2']);
      });
    });

    group('isFavorite', () {
      test('returns true for a favorited book', () async {
        await service.addFavorite('book-1');
        expect(await service.isFavorite('book-1'), isTrue);
      });

      test('returns false for a non-favorited book', () async {
        expect(await service.isFavorite('book-1'), isFalse);
      });

      test('returns false after a book is removed from favorites', () async {
        await service.addFavorite('book-1');
        await service.removeFavorite('book-1');
        expect(await service.isFavorite('book-1'), isFalse);
      });
    });

    group('persistence and data recovery', () {
      test('handles invalid JSON gracefully by returning empty list', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_book_ids': 'not valid json {{{',
        });
        service = FavoritesService();

        final result = await service.getFavoriteIds();
        expect(result, isEmpty);
      });

      test('handles non-list JSON gracefully by returning empty list', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_book_ids': jsonEncode({'key': 'value'}),
        });
        service = FavoritesService();

        final result = await service.getFavoriteIds();
        expect(result, isEmpty);
      });

      test('handles null stored value by returning empty list', () async {
        SharedPreferences.setMockInitialValues({});
        service = FavoritesService();

        final result = await service.getFavoriteIds();
        expect(result, isEmpty);
      });

      test('survives app restart by reading from shared_preferences',
          () async {
        // Simulate first session: add favorites.
        await service.addFavorite('book-1');
        await service.addFavorite('book-2');

        // Simulate app restart: create new service instance with same prefs.
        final newService = FavoritesService();
        final result = await newService.getFavoriteIds();
        expect(result, ['book-2', 'book-1']);
      });
    });

    group('ordering', () {
      test('maintains recency order across multiple additions', () async {
        await service.addFavorite('alpha');
        await service.addFavorite('beta');
        await service.addFavorite('gamma');
        await service.addFavorite('delta');

        final result = await service.getFavoriteIds();
        expect(result, ['delta', 'gamma', 'beta', 'alpha']);
      });

      test('removal does not affect order of remaining items', () async {
        await service.addFavorite('first');
        await service.addFavorite('second');
        await service.addFavorite('third');

        await service.removeFavorite('second');

        final result = await service.getFavoriteIds();
        expect(result, ['third', 'first']);
      });
    });
  });
}
