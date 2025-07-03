class Category {
  final String id;
  final String name;
  final List<double> prices;
  final bool isUserDefined;

  Category({
    required this.id,
    required this.name,
    required this.prices,
    this.isUserDefined = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'prices': prices,
        'isUserDefined': isUserDefined,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        prices: List<double>.from(json['prices'] as List),
        isUserDefined: json['isUserDefined'] as bool? ?? false,
      );

  Category copyWith({
    String? id,
    String? name,
    List<double>? prices,
    bool? isUserDefined,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      prices: prices ?? this.prices,
      isUserDefined: isUserDefined ?? this.isUserDefined,
    );
  }
}
