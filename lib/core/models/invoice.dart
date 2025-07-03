import 'item.dart'; // تأكد من استيراد موديل Item

class Invoice {
  final String id;
  final DateTime dateTime;
  final List<Item> items;
  final double total;

  Invoice({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'items': items
          .map((item) => item.toJson())
          .toList(), // تحويل الـ Items لـ JSON
      'total': total,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      items: (map['items'] as List)
          .map((itemMap) => Item.fromJson(itemMap as Map<String, dynamic>))
          .toList(),
      total: map['total'] as double,
    );
  }
}
