# Learning Guide — Book Recommendation Teaching Shell

This guide contains step-by-step exercises for implementing the scaffolded features in this project. Each exercise builds on the patterns demonstrated in the **MockDataService reference implementation** and earlier exercises.

## Before You Start

1. **Study the reference implementation** — Read through `lib/services/mock_data_service.dart` carefully. It shows how the `BookDataSource` interface is implemented, how data flows from service → provider → screen, and how filtering/search work.
2. **Understand the architecture** — Services provide data, Riverpod providers manage state, and screens render UI. Changes in providers automatically rebuild watching widgets.
3. **Run the app first** — Execute `flutter run`. The app compiles and runs out of the box using `MockDataService` — you never have a broken starting point. Each exercise adds real functionality on top of the working shell.
4. **Read the inline TODO comments** — Every stub file has detailed comments explaining exactly what to implement, including code hints.

### How the Teaching Shell Works

```
lib/
├── config/          # App configuration and router
├── models/          # Data models (Book, Genre, UserPreferences)
├── providers/       # Riverpod state management (one stubbed)
├── screens/         # UI screens (presentation layer)
├── services/        # Data services (reference + stubs)
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

The app has **one working reference** (`MockDataService`) and **six stubs** for you to implement. Each exercise below tells you what already works and what's broken until you complete it.

---

## Exercise 1: Genre Preference Persistence

**Difficulty:** ⭐ Beginner
**Stub file:** `lib/services/preferences_service.dart`
**Reference to study:** [SharedPreferences docs](https://pub.dev/packages/shared_preferences) — `getString`, `setString`, `remove`
**Concept taught:** Basic SharedPreferences read/write/remove operations

### Background

The genre filter dropdown on the book list screen lets users select a genre (Fiction, Mystery, etc.) to narrow displayed books. Right now this filter works within a session, but when the user closes and reopens the app, the selection resets to "All" because the stub's `getSelectedGenre()` always returns `null` and `setSelectedGenre()` does nothing.

**What already works:** The genre filter UI, dropdown interaction, and book filtering logic are all functional. The provider reads from `PreferencesService` on startup and writes to it when the user changes the filter.

**What's broken until you implement it:** The selected genre does not persist across app restarts. It always resets to "All".

### Steps

1. Open `lib/services/preferences_service.dart` and locate the `getSelectedGenre()` method.
2. Replace the stub body with a real SharedPreferences read:
   ```dart
   final prefs = await SharedPreferences.getInstance();
   return prefs.getString(_genreKey);
   ```
3. Implement `setSelectedGenre()` — if the genre is `null`, remove the key; otherwise store the string:
   ```dart
   final prefs = await SharedPreferences.getInstance();
   if (genre == null) {
     await prefs.remove(_genreKey);
   } else {
     await prefs.setString(_genreKey, genre);
   }
   ```
4. Implement `clearPreferences()` using `prefs.remove(_genreKey)`.
5. Run the app, select a genre filter, close the app completely, reopen it, and verify the filter persists.

### Success Criteria

- [ ] Selecting "Science Fiction" as a filter, closing the app, and reopening shows "Science Fiction" still selected
- [ ] Selecting "All" (clearing the filter) and restarting shows no genre filter active
- [ ] Calling `clearPreferences()` resets the stored genre to null
- [ ] The app does not crash if SharedPreferences is unavailable (graceful null return)

### Tips

- This is the simplest service in the project — only 3 methods, each 2–3 lines of real code.
- The `_genreKey` constant is already defined for you — use it for consistency.
- `SharedPreferences.getInstance()` is async — always `await` it.
- Test by using hot restart (not hot reload) since hot reload preserves in-memory state.
- If you're unsure about the pattern, the TODO comments in the file include complete code hints.

---

## Exercise 2: Favorites Persistence

**Difficulty:** ⭐⭐ Intermediate
**Stub file:** `lib/services/favorites_service.dart`
**Reference to study:** Your Exercise 1 solution (`preferences_service.dart`) — same SharedPreferences pattern but with JSON encoding for a list
**Concept taught:** JSON encode/decode, list persistence, error recovery from corrupted data

### Background

The favorites system lets users tap a heart icon to save books they love. The service stores a JSON-encoded list of book IDs in SharedPreferences under the key `favorite_book_ids`. The list is ordered most-recently-added first.

Currently, the stub's `_ensureInitialized()` never loads from disk, `_persist()` never writes, and `addFavorite()`/`removeFavorite()` never modify the list. The provider layer (`FavoritesNotifier`) calls these methods, so once you implement them, the UI "just works."

**What already works:** The heart icon UI, the favorites screen layout, and the `FavoritesNotifier` (which calls this service). The `getFavoriteIds()` and `isFavorite()` methods already delegate to the in-memory cache correctly.

**What's broken until you implement it:** Favorites don't survive app restarts. Tapping the heart icon doesn't actually add anything to the list because `addFavorite()` is a no-op.

### Steps

1. Open `lib/services/favorites_service.dart` and locate `_ensureInitialized()`.
2. Implement loading from SharedPreferences with JSON decoding and error recovery:
   ```dart
   if (_initialized) return;
   final prefs = await SharedPreferences.getInstance();
   final storedJson = prefs.getString(_storageKey);
   if (storedJson != null) {
     try {
       final decoded = jsonDecode(storedJson);
       if (decoded is List) {
         _favoriteIds = decoded.cast<String>().toList();
       }
     } catch (_) {
       // Corrupted data — reset to empty list
       _favoriteIds = [];
     }
   }
   _initialized = true;
   ```
3. Implement `_persist()` to encode and write:
   ```dart
   try {
     final prefs = await SharedPreferences.getInstance();
     return await prefs.setString(_storageKey, jsonEncode(_favoriteIds));
   } catch (_) {
     return false;
   }
   ```
4. Implement `addFavorite()` with optimistic insert + rollback:
   ```dart
   _favoriteIds.insert(0, bookId);
   final success = await _persist();
   if (!success) {
     _favoriteIds.remove(bookId);
     throw Exception('Failed to persist favorite');
   }
   ```
5. Implement `removeFavorite()` with optimistic remove + rollback:
   ```dart
   _favoriteIds.removeAt(index);
   final success = await _persist();
   if (!success) {
     _favoriteIds.insert(index, bookId);
     throw Exception('Failed to persist favorite removal');
   }
   ```
6. Test: tap a heart, close the app, reopen, and verify the book is still favorited.

### Success Criteria

- [ ] Tapping the heart icon on a book adds it to favorites
- [ ] Favorites persist across full app restarts
- [ ] Unfavoriting a book removes it and the change persists
- [ ] The favorites list is ordered most-recently-added first
- [ ] If stored JSON is corrupted (e.g., `"not valid json!!"`), the service gracefully resets to an empty list instead of crashing
- [ ] If `_persist()` fails, the in-memory state rolls back to its previous value

### Tips

- `jsonEncode` and `jsonDecode` come from `dart:convert` (already imported in the stub).
- The `_initialized` guard prevents redundant disk reads — respect it.
- Test corruption recovery by manually writing invalid JSON to the `favorite_book_ids` key in SharedPreferences (using the debugger or a test).
- The optimistic update + rollback pattern is crucial — Exercise 3 builds directly on this concept at the provider layer.

---

## Exercise 3: Optimistic Updates with Rollback

**Difficulty:** ⭐⭐ Intermediate
**Stub file:** `lib/providers/favorites_provider.dart`
**Reference to study:** The `FavoritesService` from Exercise 2 — same optimistic pattern but at the state management layer
**Concept taught:** Riverpod StateNotifier, optimistic UI patterns, try/catch/rollback

### Background

The `FavoritesNotifier` is a Riverpod `StateNotifier<List<String>>` that manages the current list of favorite book IDs. When a user taps the heart icon, the state should update instantly (optimistic) so the UI feels responsive. If the underlying persistence (Exercise 2's `FavoritesService`) fails, the state must roll back.

Currently, `addFavorite()` and `removeFavorite()` in the notifier are no-ops — they return immediately without changing state. The `_loadFavorites()` method already works (it reads from the service on init).

**What already works:** Initial loading of favorites from the service, the `favoritesProvider` definition, and the UI widgets that watch this provider. Other providers (like `recommendationsProvider`) also watch this provider, so favorites changes automatically trigger recommendation regeneration.

**What's broken until you implement it:** Tapping the heart icon does nothing visible. The icon doesn't toggle because `state` never changes.

### Steps

1. Open `lib/providers/favorites_provider.dart` and locate the `addFavorite()` method.
2. Implement the optimistic add pattern:
   ```dart
   if (state.contains(bookId)) return; // already favorited
   final previousState = state;
   state = [bookId, ...state]; // optimistic: add to front
   try {
     await _favoritesService.addFavorite(bookId);
   } catch (e) {
     state = previousState; // rollback on failure
     rethrow; // let UI show error SnackBar
   }
   ```
3. Implement `removeFavorite()` with the same pattern:
   ```dart
   if (!state.contains(bookId)) return; // not in list
   final previousState = state;
   state = state.where((id) => id != bookId).toList(); // optimistic remove
   try {
     await _favoritesService.removeFavorite(bookId);
   } catch (e) {
     state = previousState; // rollback on failure
     rethrow;
   }
   ```
4. Test: tap a heart icon and observe it fills immediately. Verify that if you simulate a persistence failure (e.g., throw in `FavoritesService._persist()`), the heart icon reverts.

### Success Criteria

- [ ] Tapping the heart icon immediately shows the filled heart (no loading delay)
- [ ] Tapping again immediately shows the unfilled heart
- [ ] If persistence fails, the heart icon reverts to its previous state within one frame
- [ ] A `SnackBar` error appears when a persistence failure occurs (the rethrown exception is caught by the UI)
- [ ] Changes to favorites automatically trigger the recommendations provider to regenerate suggestions

### Tips

- In Riverpod, assigning a new value to `state` triggers all watching widgets to rebuild. That's why optimistic updates feel instant.
- Always save `previousState` *before* mutating `state` — you need the original value for rollback.
- The `rethrow` is important — without it, the UI layer never knows the operation failed and can't show an error message.
- You can test rollback by temporarily making `FavoritesService._persist()` always return `false`.
- This exercise is small (two methods, ~10 lines each) but teaches a pattern used in production apps everywhere.

---

## Exercise 4: Recommendation Algorithm

**Difficulty:** ⭐⭐⭐ Advanced
**Stub file:** `lib/services/recommendation_service.dart`
**Reference to study:** `lib/services/mock_data_service.dart` — data access patterns (`getAllBooks()`, filtering with `.where()`)
**Concept taught:** Collection manipulation, sorting with multiple keys, frequency analysis

### Background

The Recommendations tab shows books the user might enjoy based on their favorites. The algorithm analyzes which genres appear most frequently in the user's favorites, then selects non-favorited books from those genres, ranked by genre frequency.

Currently, `getRecommendations()` returns an empty list, so the Recommendations tab always shows "No recommendations yet — favorite some books to get started!"

**What already works:** The Recommendations screen UI, the provider that calls this service, and the automatic regeneration when favorites change (thanks to Exercise 3). The `BookDataSource` interface provides access to the full book catalog.

**What's broken until you implement it:** The Recommendations tab is permanently empty regardless of how many books the user has favorited.

### Steps

1. Open `lib/services/recommendation_service.dart` and locate `getRecommendations()`.
2. Fetch all books from the data source:
   ```dart
   final allBooks = await dataSource.getAllBooks();
   ```
3. Handle the empty-favorites case — return up to 5 books from the genres with the most available books:
   ```dart
   if (favoriteBookIds.isEmpty) {
     final genreCount = <String, int>{};
     for (final book in allBooks) {
       genreCount[book.genre] = (genreCount[book.genre] ?? 0) + 1;
     }
     final sortedGenres = genreCount.keys.toList()
       ..sort((a, b) {
         final countCompare = genreCount[b]!.compareTo(genreCount[a]!);
         return countCompare != 0 ? countCompare : a.compareTo(b);
       });
     // Collect books from top genres until we have 5
     final results = <Book>[];
     for (final genre in sortedGenres) {
       final booksInGenre = allBooks.where((b) => b.genre == genre).toList()
         ..sort((a, b) => a.title.compareTo(b.title));
       for (final book in booksInGenre) {
         if (results.length >= 5) break;
         results.add(book);
       }
       if (results.length >= 5) break;
     }
     return results;
   }
   ```
4. Build genre frequency from the user's favorites:
   ```dart
   final favoriteIdSet = favoriteBookIds.toSet();
   final favoriteBooks = allBooks.where((b) => favoriteIdSet.contains(b.id)).toList();
   final genreFrequency = <String, int>{};
   for (final book in favoriteBooks) {
     genreFrequency[book.genre] = (genreFrequency[book.genre] ?? 0) + 1;
   }
   ```
5. Filter candidates (not already favorited, in a favorited genre):
   ```dart
   final candidates = allBooks.where((b) =>
     !favoriteIdSet.contains(b.id) &&
     genreFrequency.containsKey(b.genre)
   ).toList();
   ```
6. Sort candidates by genre frequency (descending), then alphabetical genre, then alphabetical title:
   ```dart
   candidates.sort((a, b) {
     final freqCompare = genreFrequency[b.genre]!.compareTo(genreFrequency[a.genre]!);
     if (freqCompare != 0) return freqCompare;
     final genreCompare = a.genre.compareTo(b.genre);
     if (genreCompare != 0) return genreCompare;
     return a.title.compareTo(b.title);
   });
   ```
7. Return at most 5:
   ```dart
   return candidates.take(5).toList();
   ```

### Success Criteria

- [ ] With no favorites, the Recommendations tab shows up to 5 books from the most populated genres
- [ ] After favoriting 2 Fiction books and 1 Mystery book, recommendations prioritize Fiction over Mystery
- [ ] Already-favorited books never appear in recommendations
- [ ] Recommendations update automatically when a book is favorited or unfavorited
- [ ] Results are capped at 5 books maximum
- [ ] Within the same genre frequency, books are sorted alphabetically by title

### Tips

- The algorithm has 7 distinct steps — implement them one at a time and test incrementally.
- Use `dart:collection` or basic `Map<String, int>` for frequency counting — no external packages needed.
- The empty-favorites fallback is easy to overlook — test it by unfavoriting everything.
- The sorting logic uses three keys — get the primary (frequency) working first, then add secondary and tertiary.
- All the code hints are in the TODO comments inside the stub file — they're nearly copy-paste ready.

---

## Exercise 5: Open Library API Integration

**Difficulty:** ⭐⭐⭐ Advanced
**Stub file:** `lib/services/api_service_stub.dart`
**Reference to study:** `lib/services/mock_data_service.dart` — same `BookDataSource` interface, same return types
**Concept taught:** HTTP requests, JSON parsing, API response mapping, error handling

### Background

The `ApiServiceStub` implements the same `BookDataSource` interface as `MockDataService`, but fetches real book data from the [Open Library API](https://openlibrary.org/developers/api) over HTTP. Each method currently returns an empty list or null.

Once implemented, you toggle `useRealApi = true` in `lib/config/app_config.dart` and the entire app switches from mock data to live internet data — no other code changes needed.

**What already works:** The `BookDataSource` interface, the `AppConfig.useRealApi` toggle, and the provider layer that selects between mock and API service. The `Book` model with its `fromJson` factory is ready to use.

**What's broken until you implement it:** With `useRealApi = true`, all screens show empty states because every method returns `[]` or `null`.

### Steps

1. Add the `http` package to `pubspec.yaml`:
   ```yaml
   dependencies:
     http: ^1.1.0
   ```
   Run `flutter pub get`.

2. Implement `getAllBooks()` — fetch from the search endpoint:
   ```dart
   final url = Uri.parse('https://openlibrary.org/search.json?q=*&limit=20');
   final response = await http.get(url).timeout(const Duration(seconds: 10));
   if (response.statusCode == 200) {
     final data = jsonDecode(response.body) as Map<String, dynamic>;
     final docs = data['docs'] as List<dynamic>;
     return docs.map((doc) => Book(
       id: doc['key'] as String,
       title: doc['title'] as String? ?? 'Untitled',
       author: (doc['author_name'] as List?)?.first as String? ?? 'Unknown Author',
       genre: (doc['subject'] as List?)?.first as String? ?? 'General',
       description: 'Fetched from Open Library',
       coverUrl: doc['cover_i'] != null
           ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg'
           : null,
       publishYear: doc['first_publish_year'] as int?,
     )).toList();
   }
   return [];
   ```

3. Implement `getBooksByGenre()` — use the subjects endpoint:
   ```dart
   final slug = genre.toLowerCase().replaceAll(' ', '_');
   final url = Uri.parse('https://openlibrary.org/subjects/$slug.json?limit=20');
   ```
   Note: This endpoint returns a `works` array with different field names (`authors[0].name` instead of `author_name`).

4. Implement `searchBooks()` — use URL-encoded query:
   ```dart
   final encodedQuery = Uri.encodeQueryComponent(query);
   final url = Uri.parse('https://openlibrary.org/search.json?q=$encodedQuery&limit=20');
   ```

5. Implement `getBookById()` — handle the description field which can be a plain String or a `{"type": "...", "value": "..."}` object:
   ```dart
   String description = '';
   if (json['description'] is String) {
     description = json['description'] as String;
   } else if (json['description'] is Map) {
     description = (json['description'] as Map)['value'] as String? ?? '';
   }
   ```

6. Toggle the flag in `lib/config/app_config.dart`: set `useRealApi = true`.

7. Run with internet access and verify live data loads.

### Success Criteria

- [ ] `flutter pub get` completes without errors after adding the `http` package
- [ ] Setting `useRealApi = true` causes the app to fetch real book data from Open Library
- [ ] The book list screen displays books with titles and authors from the API
- [ ] Searching for "The Hobbit" returns relevant results
- [ ] Filtering by genre (e.g., "Fiction") returns books tagged with that subject
- [ ] Tapping a book shows its detail screen with a description
- [ ] The app handles no-internet gracefully (no crash — shows empty state or error message)
- [ ] Setting `useRealApi` back to `false` restores mock data instantly

### Tips

- Start with `searchBooks()` — it's the simplest endpoint and lets you verify your HTTP + JSON pipeline works.
- The Open Library search endpoint returns a `docs` array, while the subjects endpoint returns a `works` array — they have different field structures.
- Not every book has a `cover_i` field. Always null-check before constructing the cover URL.
- Add `.timeout(const Duration(seconds: 10))` to every HTTP call to avoid hanging on slow connections.
- Catch `SocketException` (from `dart:io`) for no-internet scenarios and `TimeoutException` (from `dart:async`) for slow responses.
- The API is free but shared — be respectful with request frequency. Open Library may return HTTP 429 if you hit it too fast.

---

## Exercise 6: Supabase Backend

**Difficulty:** ⭐⭐⭐ Advanced
**Stub file:** `lib/services/supabase_service.dart`
**Reference to study:** `lib/services/mock_data_service.dart` (data access patterns), `lib/services/favorites_service.dart` (favorites CRUD)
**Concept taught:** Database queries, cloud backend, SQL schemas, connection handling

### Background

The `SupabaseService` replaces both `MockDataService` (for books) and `FavoritesService` (for favorites) with a real PostgreSQL database hosted on Supabase. Books are stored in a `books` table and favorites in a `favorites` table with a foreign key relationship.

Currently, every method falls back to `MockDataService` and sets `didFallback = true`. Once you implement the real queries and provide valid credentials, the app connects to your Supabase project.

**What already works:** The `_mapColumnNames` helper for converting snake_case to camelCase, the `_fallback` mechanism, and the `SupabaseConfig` class that reads credentials from `--dart-define` environment variables. The UI already checks `didFallback` to show a connectivity warning SnackBar.

**What's broken until you implement it:** All data comes from MockDataService (the fallback). No data persists to a cloud database. Favorites are only local.

### Prerequisites

Before writing code, set up your Supabase project:

1. Go to [app.supabase.com](https://app.supabase.com) and create a new project.
2. Open the SQL Editor (Dashboard → SQL Editor → New Query).
3. Run the migration SQL found at the top of `lib/services/supabase_service.dart` to create the `books` and `favorites` tables.
4. Seed the `books` table with sample data (use the same books from `MockDataService` as a starting point).
5. Note your Project URL and anon key (Settings → API).

### Steps

1. Implement `getAllBooks()` using a Supabase select query:
   ```dart
   didFallback = false;
   try {
     final response = await Supabase.instance.client
         .from('books')
         .select()
         .timeout(_timeout);
     return (response as List)
         .map((json) => Book.fromJson(_mapColumnNames(json)))
         .toList();
   } catch (_) {
     didFallback = true;
     return _fallback.getAllBooks();
   }
   ```

2. Implement `getBooksByGenre()` — add `.eq('genre', genre)` filter.

3. Implement `searchBooks()` — use `.or('title.ilike.%$query%,author.ilike.%$query%')`.

4. Implement `getBookById()` — use `.eq('id', id).maybeSingle()`.

5. Implement `getFavoriteBookIds()` — select `book_id` from `favorites` filtered by `user_id`.

6. Implement `addFavorite()` — insert into the `favorites` table.

7. Implement `removeFavorite()` — delete from `favorites` matching `user_id` and `book_id`.

8. Run the app with real credentials:
   ```
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

### Success Criteria

- [ ] The Supabase project has `books` and `favorites` tables with correct schemas
- [ ] The `books` table contains at least 15 sample rows across 5+ genres
- [ ] Running with real credentials displays books from the Supabase database
- [ ] Genre filtering works against the database (only matching genres returned)
- [ ] Search returns books whose title or author matches the query (case-insensitive)
- [ ] Adding a favorite inserts a row into the `favorites` table
- [ ] Removing a favorite deletes the corresponding row
- [ ] If Supabase is unreachable, the app falls back to mock data within 10 seconds
- [ ] A SnackBar warning appears when the fallback is triggered (`didFallback = true`)
- [ ] Removing the `--dart-define` flags causes the app to use mock data without errors or crashes

### Tips

- Start with `getAllBooks()` — it's the simplest query (just `.select()`) and lets you verify your connection works.
- Use the `_mapColumnNames` helper already provided in the file to convert column names.
- The `favorites` table has a `UNIQUE(user_id, book_id)` constraint — inserting a duplicate throws. Consider catching the error or using `.upsert()`.
- For local development, generate a temporary UUID for `user_id`. Later you can integrate Supabase Auth.
- Check `SupabaseConfig.hasPlaceholderCredentials` before attempting a connection to avoid unnecessary timeout waits.
- Use the Supabase dashboard's Table Editor to visually inspect your data while developing.
- Every method should wrap queries in try/catch and fall back to `_fallback` on failure — this makes the app resilient.

---

## General Tips

- **Work in order** — The exercises build on each other. Exercise 2 references Exercise 1's pattern, Exercise 3 references Exercise 2's service, and Exercise 4 depends on Exercise 3 working.
- **Start with the service layer** — Get the data operations working before worrying about UI.
- **Test incrementally** — Implement one method at a time and verify it works before moving on.
- **Read the inline TODO comments** — Every stub function has detailed step-by-step guidance with code hints.
- **Use hot restart, not hot reload** — Persistence tests require a full restart to verify data survives.
- **Toggle flags to compare** — Use `useRealApi` in `AppConfig` to instantly switch between mock and live data.
- **Check the terminal output** — Flutter prints helpful error messages for network failures, JSON parse errors, and SharedPreferences issues.

---

## What's Next?

After completing all six exercises, you will have transformed this teaching shell into a fully-featured application with:

- Persistent user preferences and favorites (local storage)
- Optimistic UI updates with rollback (professional UX pattern)
- Intelligent recommendation engine (algorithmic logic)
- Live book data from the Open Library API (HTTP integration)
- Cloud database backend with Supabase (full-stack architecture)

Consider these bonus challenges to deepen your learning:

1. **Add Supabase Auth** — Implement user login so each user has their own favorites list
2. **Add pagination** — Modify `getAllBooks()` to load books in pages of 20 using Supabase's `.range()` method
3. **Add a book cover cache** — Use the `cached_network_image` package to cache cover images loaded from Open Library
4. **Write unit tests** — Add tests for your services using mock HTTP clients and fake SharedPreferences
5. **Combine API + Supabase** — Fetch books from Open Library but persist favorites in Supabase for the best of both worlds
6. **Add reading lists** — Create a new table and service for user-created reading lists with drag-and-drop reordering
