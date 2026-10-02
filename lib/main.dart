import 'package:flutter/material.dart';
import 'services/book_storage.dart';
import 'models/book.dart';
import 'screens/add_book_screen.dart';
import 'widgets/book_card.dart';

void main() {
  runApp(const BookStudioApp());
}

class BookStudioApp extends StatelessWidget {
  const BookStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BookStudio',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> get _filteredBooks {
    final query = _searchQuery.toLowerCase();

    return _books.where((book) {
      final matchesSearch =
          query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == null || book.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  final List<Book> _books = [];

  final BookStorage _storage = BookStorage();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  BookStatus? _selectedStatus;

  Future<void> _addBook() async {
    final Book? newBook = await Navigator.push<Book>(
      context,

      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );

    if (newBook != null) {
      setState(() {
        _books.add(newBook);
      });

      await _storage.saveBooks(_books);
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        onSelected();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _storage.loadBooks();

    if (!mounted) {
      return;
    }

    setState(() {
      _books.addAll(books);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 BookStudio')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск книг...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  label: 'Все',
                  selected: _selectedStatus == null,
                  onSelected: () {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '💡 Идея',
                  selected: _selectedStatus == BookStatus.idea,
                  onSelected: () {
                    setState(() {
                      _selectedStatus = BookStatus.idea;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '✍️ В процессе',
                  selected: _selectedStatus == BookStatus.inProgress,
                  onSelected: () {
                    setState(() {
                      _selectedStatus = BookStatus.inProgress;
                    });
                  },
                ),

                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '📖 Завершена',
                  selected: _selectedStatus == BookStatus.completed,
                  onSelected: () {
                    setState(() {
                      _selectedStatus = BookStatus.completed;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 70),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'У вас пока нет книг'
                              : 'Книги не найдены',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Создайте свою первую книгу'
                              : 'Попробуйте изменить запрос',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];

                      return BookCard(
                        book: book,
                        onChanged: () async {
                          setState(() {});

                          await _storage.saveBooks(_books);
                        },
                        onDeleted: () async {
                          setState(() {
                            _books.remove(book);
                          });

                          await _storage.saveBooks(_books);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
