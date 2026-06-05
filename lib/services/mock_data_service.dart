/// Reference Implementation
///
/// This service provides offline development data for the Book Recommendation app.
/// It implements [BookDataSource] with hardcoded sample books so the app functions
/// immediately without any external API or database connection.
///
/// When you are ready to integrate a real data source, see [ApiServiceStub] in
/// `api_service_stub.dart` for Open Library API integration guidance, or
/// [SupabaseService] in `supabase_service.dart` for database-backed persistence.
library;

import '../models/book.dart';
import 'book_data_source.dart';

/// Mock implementation of [BookDataSource] providing sample book data for
/// offline development and as a reference for learners implementing the
/// API_Service_Stub or Supabase_Service.
class MockDataService implements BookDataSource {
  // Sample book catalog covering 5+ genres with publish years spanning
  // the 1990s, 2000s, 2010s, and 2020s.
  final List<Book> _books = const [
    // Fiction
    Book(
      id: '1',
      title: 'The Midnight Library',
      author: 'Matt Haig',
      genre: 'Fiction',
      description:
          'A woman finds herself in a library between life and death, where each book offers a different life she could have lived.',
      publishYear: 2020,
    ),
    Book(
      id: '2',
      title: 'A Man Called Ove',
      author: 'Fredrik Backman',
      genre: 'Fiction',
      description:
          'A grumpy yet lovable man discovers unexpected friendships in his neighborhood after his wife passes away.',
      publishYear: 2012,
    ),
    Book(
      id: '3',
      title: 'The Kite Runner',
      author: 'Khaled Hosseini',
      genre: 'Fiction',
      description:
          'A tale of friendship, betrayal, and redemption set against the backdrop of Afghanistan from the 1970s to the 2000s.',
      publishYear: 2003,
    ),
    // Science Fiction
    Book(
      id: '4',
      title: 'Project Hail Mary',
      author: 'Andy Weir',
      genre: 'Science Fiction',
      description:
          'A lone astronaut must save Earth from an extinction-level threat using science, ingenuity, and an unlikely alien ally.',
      publishYear: 2021,
    ),
    Book(
      id: '5',
      title: 'Dune',
      author: 'Frank Herbert',
      genre: 'Science Fiction',
      description:
          'On a desert planet, a young nobleman navigates politics and ecology to fulfill a prophetic destiny.',
      publishYear: 1965,
    ),
    Book(
      id: '6',
      title: 'Neuromancer',
      author: 'William Gibson',
      genre: 'Science Fiction',
      description:
          'A washed-up computer hacker is hired for one last job in a neon-lit cyberpunk future ruled by AI.',
      publishYear: 1984,
    ),
    // Mystery
    Book(
      id: '7',
      title: 'The Girl with the Dragon Tattoo',
      author: 'Stieg Larsson',
      genre: 'Mystery',
      description:
          'A journalist and a hacker investigate a decades-old disappearance tied to a wealthy Swedish family.',
      publishYear: 2005,
    ),
    Book(
      id: '8',
      title: 'Gone Girl',
      author: 'Gillian Flynn',
      genre: 'Mystery',
      description:
          'A marriage unravels through alternating perspectives when a wife vanishes on their anniversary.',
      publishYear: 2012,
    ),
    Book(
      id: '9',
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      genre: 'Mystery',
      description:
          'A therapist becomes obsessed with a mute woman accused of murdering her husband in their home.',
      publishYear: 2019,
    ),
    // Non-Fiction
    Book(
      id: '10',
      title: 'Sapiens: A Brief History of Humankind',
      author: 'Yuval Noah Harari',
      genre: 'Non-Fiction',
      description:
          'An exploration of how Homo sapiens came to dominate the planet through cognitive, agricultural, and scientific revolutions.',
      publishYear: 2011,
    ),
    Book(
      id: '11',
      title: 'Atomic Habits',
      author: 'James Clear',
      genre: 'Non-Fiction',
      description:
          'A practical guide to building good habits and breaking bad ones through small incremental changes.',
      publishYear: 2018,
    ),
    Book(
      id: '12',
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      genre: 'Non-Fiction',
      description:
          'A Nobel laureate reveals how two systems of thought shape our judgments, decisions, and behavior.',
      publishYear: 2011,
    ),
    // Fantasy
    Book(
      id: '13',
      title: 'The Name of the Wind',
      author: 'Patrick Rothfuss',
      genre: 'Fantasy',
      description:
          'A legendary figure recounts his rise from orphaned street urchin to the most notorious wizard alive.',
      publishYear: 2007,
    ),
    Book(
      id: '14',
      title: 'Mistborn: The Final Empire',
      author: 'Brandon Sanderson',
      genre: 'Fantasy',
      description:
          'A street thief with rare powers joins a crew plotting to overthrow an immortal tyrant ruling their world.',
      publishYear: 2006,
    ),
    Book(
      id: '15',
      title: 'The Hobbit',
      author: 'J.R.R. Tolkien',
      genre: 'Fantasy',
      description:
          'A homebody hobbit embarks on an unexpected adventure with dwarves to reclaim a mountain treasure from a dragon.',
      publishYear: 1937,
    ),
    // Additional books for richer data coverage
    Book(
      id: '16',
      title: 'Educated',
      author: 'Tara Westover',
      genre: 'Non-Fiction',
      description:
          'A memoir of a woman who grows up in a survivalist family and educates herself to earn a PhD from Cambridge.',
      publishYear: 2018,
    ),
    Book(
      id: '17',
      title: 'The Martian',
      author: 'Andy Weir',
      genre: 'Science Fiction',
      description:
          'An astronaut stranded on Mars must use botany and engineering to survive until rescue arrives.',
      publishYear: 2011,
    ),
  ];

  /// Returns all sample books from the mock catalog.
  ///
  /// This mirrors the behavior expected from API_Service_Stub.getAllBooks()
  /// which would fetch all books from the Open Library or Supabase backend.
  @override
  Future<List<Book>> getAllBooks() async {
    return _books;
  }

  /// Returns books matching the specified [genre] exactly.
  ///
  /// Genre matching is case-sensitive to align with the predefined genre
  /// categories (Fiction, Science Fiction, Mystery, Non-Fiction, Fantasy).
  /// The API_Service_Stub equivalent would use a genre query parameter.
  @override
  Future<List<Book>> getBooksByGenre(String genre) async {
    return _books.where((book) => book.genre == genre).toList();
  }

  /// Returns books whose title or author contains [query] (case-insensitive).
  ///
  /// The API_Service_Stub equivalent would send the query to the
  /// Open Library search endpoint: https://openlibrary.org/search.json?q={query}
  @override
  Future<List<Book>> searchBooks(String query) async {
    final lowerQuery = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
          book.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Returns a single book by its [id], or null if no book matches.
  ///
  /// The API_Service_Stub equivalent would fetch a book by its Open Library
  /// work key or Supabase UUID primary key.
  @override
  Future<Book?> getBookById(String id) async {
    try {
      return _books.firstWhere((book) => book.id == id);
    } on StateError {
      return null;
    }
  }
}
