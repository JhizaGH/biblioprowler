import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'statistics_page.dart'; // Importamos la página de estadísticas

/// ============================================================================
/// MODELO DE DATOS PARA LIBROS
/// ============================================================================
/// Clase que representa un libro con título, autor, estado de lectura y valoración
class Book {
  String title;   // Título del libro
  String author;  // Autor del libro
  String status;  // Estado: "Leído", "Leyendo", "Por leer", "Abandonado"
  int rating;     // Valoración de 0 a 5 estrellas

  // Constructor de la clase Book
  Book({
    required this.title,
    required this.author,
    required this.status,
    this.rating = 0,
  });

  // Convierte el libro a formato JSON para almacenamiento
  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'status': status,
        'rating': rating,
      };

  // Crea un libro desde formato JSON
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        title: json['title'],
        author: json['author'],
        status: json['status'],
        rating: json['rating'] ?? 0,
      );
}

/// ============================================================================
/// CLASE AUXILIAR PARA GUARDAR Y CARGAR LIBROS
/// ============================================================================
/// Gestiona el almacenamiento persistente de libros usando SharedPreferences
class BookStorage {
  static const String _key = 'books'; // Clave para almacenar los libros

  // Guarda la lista de libros en SharedPreferences
  static Future<void> saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = books.map((book) => book.toJson()).toList();
    prefs.setString(_key, jsonEncode(jsonList));
  }

  // Carga la lista de libros desde SharedPreferences
  static Future<List<Book>> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return []; // Si no hay datos, retorna lista vacía
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((json) => Book.fromJson(json)).toList();
  }
}

/// ============================================================================
/// WIDGET PRINCIPAL
/// ============================================================================
/// Punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inicializa los bindings de Flutter
  final books = await BookStorage.loadBooks(); // Carga los libros guardados
  runApp(MyApp(initialBooks: books));
}

/// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  final List<Book> initialBooks; // Lista inicial de libros cargados

  const MyApp({super.key, required this.initialBooks});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioprowler',
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'JetBrainsMono', // Fuente global para toda la app
      ),
      home: HomePage(initialBooks: initialBooks),
    );
  }
}

/// ============================================================================
/// WIDGET RAÍZ CON NAVEGACIÓN ENTRE PÁGINAS
/// ============================================================================
/// Gestiona la navegación entre la página de libros y estadísticas
class HomePage extends StatefulWidget {
  final List<Book> initialBooks;

  const HomePage({super.key, required this.initialBooks});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Índice de la página seleccionada
  late List<Book> books;  // Lista de libros gestionada

  @override
  void initState() {
    super.initState();
    books = widget.initialBooks; // Inicializa la lista de libros
  }

  // Lista de páginas disponibles en la navegación
  List<Widget> get _pages => [
        BookListPage(books: books, onUpdate: _saveBooks),
        StatisticsPage(books: books), // Pasamos la lista de libros
      ];

  // Maneja el cambio de pestaña en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Guarda los cambios en SharedPreferences
  Future<void> _saveBooks() async {
    await BookStorage.saveBooks(books);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Muestra la página seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// PÁGINA DE LISTA DE LIBROS
/// ============================================================================
/// Muestra la lista de libros con opciones para añadir, editar y eliminar
class BookListPage extends StatefulWidget {
  final List<Book> books;       // Lista de libros
  final VoidCallback onUpdate;  // Callback para guardar cambios

  const BookListPage({super.key, required this.books, required this.onUpdate});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late List<Book> books;

  // Retorna el color de fondo según el estado del libro
  Color _colorForStatus(String status) {
    switch (status) {
      case 'Leído':
        return Colors.green.shade100;   // Verde claro para libros leídos
      case 'Leyendo':
        return Colors.blue.shade100;    // Azul claro para libros en lectura
      case 'Por leer':
        return Colors.purple.shade100;  // Morado claro para pendientes
      case 'Abandonado':
        return Colors.red.shade100;     // Rojo claro para abandonados
      default:
        return Colors.grey.shade200;    // Gris por defecto
    }
  }

  @override
  void initState() {
    super.initState();
    books = widget.books; // Inicializa la lista de libros
  }

  // Muestra un diálogo para añadir o editar un libro
  void _showBookDialog({Book? book, int? index}) {
    // Controladores para los campos de texto
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    String selectedStatus = book?.status ?? 'Por leer';
    int selectedRating = book?.rating ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book == null ? 'Añadir libro' : 'Editar libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo para el título
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            // Campo para el autor
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Autor'),
            ),
            const SizedBox(height: 10),
            // Dropdown para seleccionar el estado
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem(value: 'Por leer', child: Text('Por leer')),
                DropdownMenuItem(value: 'Leyendo', child: Text('Leyendo')),
                DropdownMenuItem(value: 'Leído', child: Text('Leído')),
                DropdownMenuItem(value: 'Abandonado', child: Text('Abandonado')),
              ],
              onChanged: (value) => selectedStatus = value!,
            ),
            const SizedBox(height: 10),
            // Dropdown para seleccionar la valoración
            DropdownButtonFormField<int>(
              initialValue: selectedRating,
              decoration: const InputDecoration(labelText: 'Valoración'),
              items: List.generate(6, (i) {
                final stars = '★' * i + '☆' * (5 - i); // Genera estrellas
                return DropdownMenuItem(value: i, child: Text(stars));
              }),
              onChanged: (value) => selectedRating = value ?? 0,
            ),
          ],
        ),
        actions: [
          // Botón para cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Botón para guardar
          ElevatedButton(
            onPressed: () {
              final newBook = Book(
                title: titleController.text,
                author: authorController.text,
                status: selectedStatus,
                rating: selectedRating,
              );

              setState(() {
                if (book == null) {
                  books.add(newBook); // Añade nuevo libro
                } else {
                  books[index!] = newBook; // Actualiza libro existente
                }
              });

              widget.onUpdate(); // Guarda los cambios
              Navigator.pop(context);
            },
            child: Text(book == null ? 'Añadir' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  // Elimina un libro de la lista
  void _deleteBook(int index) {
    setState(() {
      books.removeAt(index);
    });
    widget.onUpdate(); // Guarda los cambios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar personalizado con fondo azul claro
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.blue.shade100, // Fondo azul claro
          alignment: Alignment.center,
          child: const Text(
            'Libros',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Cuerpo principal con Column para incluir la lista y el footer
      body: Column(
        children: [
          // Lista de libros (ocupa el espacio disponible)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: books.isEmpty
                  ? const Center(
                      child: Text('No hay libros aún. ¡Agrega uno! 📚'))
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Card(
                          color: _colorForStatus(book.status), // Color según estado
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: ListTile(
                            title: Text(book.title),
                            subtitle: Text(
                                '${book.author} — ${book.status} — ${'★' * book.rating + '☆' * (5 - book.rating)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botón para editar
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showBookDialog(book: book, index: index),
                                ),
                                // Botón para eliminar
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteBook(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Footer con texto e icono de GitHub
          _buildFooter(),
        ],
      ),
      // Botón flotante para añadir libros
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(),
        label: const Text('Añadir libro'),
        icon: const Icon(Icons.add),
      ),
    );
  }

//URL DEL SITIO

final Uri myRepo = Uri.parse('https://github.com/JhizaGH/biblioprowler');


  /// ============================================================================
  /// FOOTER PERSONALIZADO
  /// ============================================================================
  /// Widget que muestra el pie de página con texto e icono de GitHub
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey.shade200, // Fondo gris claro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Creado por Álvaro Sánchez Lugones.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(width: 8), // Espacio entre texto e icono
          // Icono de GitHub (usando Icons.code como alternativa)
          // Si tienes font_awesome_flutter, puedes usar FaIcon(FontAwesomeIcons.github)
          IconButton(
            icon: const Icon(Icons.code), // Icono alternativo (puedes cambiar por GitHub icon)
            iconSize: 20,
            color: Colors.black87,
            onPressed: () {
              launchUrl(myRepo);
            },
          ),
        ],
      ),
    );
  }
}