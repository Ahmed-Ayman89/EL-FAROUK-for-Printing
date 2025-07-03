import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/app_constants.dart';
import '../models/item.dart';

class CsvExporter {
  static Future<void> exportSales(List<Item> items, double total) async {
    if (items.isEmpty) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filename =
        '$path/${AppConstants.salesFileNamePrefix}${DateTime.now().toString().substring(0, 10)}.csv';

    final file = File(filename);
    final bool fileExists = await file.exists();

    List<List<dynamic>> rows = [];

    if (!fileExists) {
      rows.add(['الوقت', 'الصنف', 'الكمية', 'سعر الوحدة', 'التكلفة']);
    }

    final now = DateTime.now();
    for (var item in items) {
      rows.add([
        now.toString().substring(11, 19), // Time H:M:S
        item.name,
        item.quantity,
        item.unitPrice.toStringAsFixed(2),
        item.totalCost.toStringAsFixed(2),
      ]);
    }
    rows.add(["", "", "", "الإجمالي", total.toStringAsFixed(2)]);
    rows.add([]); // Empty row for separation

    String csv = const ListToCsvConverter().convert(rows);

    await file.writeAsString(csv,
        mode: FileMode.append, encoding: const SystemEncoding());
  }
}
