import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../core/models/item.dart';

@immutable
abstract class PosState {}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosLoaded extends PosState {
  final List<Item> items;
  final double total;
  final String? activeCategory;
  final List<Category> categories;

  PosLoaded({
    required this.items,
    required this.total,
    this.activeCategory,
    required this.categories,
  });

  PosLoaded copyWith({
    List<Item>? items,
    double? total,
    String? activeCategory,
    List<Category>? categories,
  }) {
    return PosLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
      activeCategory: activeCategory ?? this.activeCategory,
      categories: categories ?? this.categories,
    );
  }
}

class PosError extends PosState {
  final String message;

  PosError(this.message);
}
