import 'package:flutter/material.dart';
import 'main.dart'; // importa tu modelo Book

class StatisticsPage extends StatelessWidget {
  final List<Book> books;

  const StatisticsPage({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    // Total de libros
    final totalBooks = books.length;

    // Conteo por estado
    final readCount = books.where((b) => b.status == 'Leído').length;
    final readingCount = books.where((b) => b.status == 'Leyendo').length;
    final toReadCount = books.where((b) => b.status == 'Por leer').length;
    final droppedCount = books.where((b) => b.status == 'Abandonado').length;
    // Conteo por estrellas
    final ratingCounts = List.generate(6, (i) => books.where((b) => b.rating == i).length);

    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60),
  child: Container(
    color: Colors.green.shade100,
    alignment: Alignment.center,
    child: const Text(
      'Estadísticas',
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen por estado de los libros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Tabla de estados
            Container(
              decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 24, 24, 24), width: 2), // línea alrededor de la tabla
              borderRadius: BorderRadius.circular(4), // opcional: esquinas redondeadas
            ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Cantidad')),
                  DataColumn(label: Text('Porcentaje')),
                  ],
              rows: [
                DataRow(
                  color: WidgetStateProperty.all(const Color.fromARGB(255, 180, 255, 183)),
                  cells: [
                  const DataCell(Text('Leído')),
                  DataCell(Text('$readCount')),
                  DataCell(Text(totalBooks == 0 ? '0%' : '${(readCount / totalBooks * 100).toStringAsFixed(1)}%')),
                ]),
                DataRow(
                  color: WidgetStateProperty.all(const Color.fromARGB(255, 166, 187, 255)),
                  cells: [
                  const DataCell(Text('Leyendo')),
                  DataCell(Text('$readingCount')),
                  DataCell(Text(totalBooks == 0 ? '0%' : '${(readingCount / totalBooks * 100).toStringAsFixed(1)}%')),
                ]),
                DataRow(
                  color: WidgetStateProperty.all(const Color.fromARGB(255, 226, 154, 255)),
                  cells: [
                  const DataCell(Text('Por leer')),
                  DataCell(Text('$toReadCount')),
                  DataCell(Text(totalBooks == 0 ? '0%' : '${(toReadCount / totalBooks * 100).toStringAsFixed(1)}%')),
                ]),
                DataRow(
                  color: WidgetStateProperty.all(const Color.fromARGB(255, 255, 154, 154)),
                  cells: [
                  const DataCell(Text('Abandonado')),
                  DataCell(Text('$droppedCount')),
                  DataCell(Text(totalBooks == 0 ? '0%' : '${(droppedCount / totalBooks * 100).toStringAsFixed(1)}%')),
                ]),
                DataRow(
                  cells: [
                  const DataCell(Text('Total')),
                  DataCell(Text('$totalBooks')),
                  const DataCell(Text('100%')),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 30),

            const Text('Resumen por valoración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Tabla de estrellas
            Container(
              decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 24, 24, 24), width: 2), // línea alrededor de la tabla
              borderRadius: BorderRadius.circular(4), // opcional: esquinas redondeadas
            ),
              child: DataTable(
              columns: const [
                DataColumn(label: Text('Estrellas')),
                DataColumn(label: Text('Cantidad')),
                DataColumn(label: Text('Porcentaje')),
              ],
              rows: List.generate(6, (i) {
                final count = ratingCounts[i];
                final percentage = totalBooks == 0 ? 0 : (count / totalBooks * 100);
                final stars = '★' * i + '☆' * (5 - i);
                return DataRow(cells: [
                  DataCell(Text(stars)),
                  DataCell(Text('$count')),
                  DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                ]);
              }),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
