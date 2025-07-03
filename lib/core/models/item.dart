class Item {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalCost;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalCost,
  });

  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    double? unitPrice,
    double? totalCost,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  // >>> الدوال المهمة للتحويل إلى JSON والعكس <<<
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalCost': totalCost,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as double,
      totalCost: json['totalCost'] as double,
    );
  }
}
