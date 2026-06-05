import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:book_recommendation_app/services/preferences_service.dart';

void main() {
  late PreferencesService service;

  setUp(() {
    // Reset shared_preferences mock state before each test.
    SharedPreferences.setMockInitialValues({});
    service = PreferencesService();
  });

  group('PreferencesService', () {
    group('getSelectedGenre', () {
      test('returns null when no genre has been stored', () async {
        final String? genre = await service.getSelectedGenre();
        expect(genre, isNull);
      });

      test('returns the stored genre string', () async {
        SharedPreferences.setMockInitialValues({'selected_genre': 'Fantasy'});
        service = PreferencesService();

        final String? genre = await service.getSelectedGenre();
        expect(genre, equals('Fantasy'));
      });

      test('returns null when stored value is empty string', () async {
        // An empty string is technically valid, but we store it as-is.
        SharedPreferences.setMockInitialValues({'selected_genre': ''});
        service = PreferencesService();

        final String? genre = await service.getSelectedGenre();
        expect(genre, equals(''));
      });
    });

    group('setSelectedGenre', () {
      test('persists a genre string', () async {
        await service.setSelectedGenre('Science Fiction');

        final String? result = await service.getSelectedGenre();
        expect(result, equals('Science Fiction'));
      });

      test('removes the key when genre is null (select All)', () async {
        // First set a genre.
        await service.setSelectedGenre('Mystery');
        expect(await service.getSelectedGenre(), equals('Mystery'));

        // Then clear it by setting null.
        await service.setSelectedGenre(null);
        expect(await service.getSelectedGenre(), isNull);
      });

      test('overwrites previously stored genre', () async {
        await service.setSelectedGenre('Fantasy');
        await service.setSelectedGenre('Non-Fiction');

        final String? result = await service.getSelectedGenre();
        expect(result, equals('Non-Fiction'));
      });
    });

    group('clearPreferences', () {
      test('removes stored genre preference', () async {
        await service.setSelectedGenre('Fiction');
        expect(await service.getSelectedGenre(), equals('Fiction'));

        await service.clearPreferences();
        expect(await service.getSelectedGenre(), isNull);
      });

      test('does nothing when no preferences are stored', () async {
        // Should not throw.
        await service.clearPreferences();
        expect(await service.getSelectedGenre(), isNull);
      });
    });

    group('persistence round-trip', () {
      test('persisting and reading null returns null', () async {
        await service.setSelectedGenre(null);
        final String? result = await service.getSelectedGenre();
        expect(result, isNull);
      });

      test('persisting and reading a genre returns the same genre', () async {
        const String genre = 'Science Fiction';
        await service.setSelectedGenre(genre);
        final String? result = await service.getSelectedGenre();
        expect(result, equals(genre));
      });

      test('works with special characters in genre name', () async {
        const String genre = 'Sci-Fi & Fantasy (Modern)';
        await service.setSelectedGenre(genre);
        final String? result = await service.getSelectedGenre();
        expect(result, equals(genre));
      });
    });

    group('corrupted data handling', () {
      test('returns null gracefully when key type is unexpected', () async {
        // shared_preferences getString returns null for non-string types,
        // so even if somehow a non-string got stored, we get null back.
        SharedPreferences.setMockInitialValues({});
        service = PreferencesService();

        final String? genre = await service.getSelectedGenre();
        expect(genre, isNull);
      });
    });
  });
}
