import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/category.dart';
import '../../../core/models/invoice.dart';
import '../../../core/models/item.dart';
import '../../../core/utils/csv_exporter.dart';
import '../data/pos_data_source.dart';
import 'pos_state.dart';

class PosCubit extends Cubit<PosState> {
  final PosDataSource _dataSource;
  List<Item> _currentItems = [];
  double _currentTotal = 0.0;
  String? _activeCategory;
  List<Category> _allCategories = [];
  List<Invoice> _savedInvoices = [];
  final Uuid _uuid = Uuid();

  PosCubit(this._dataSource) : super(PosInitial()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      _allCategories =
          await _dataSource.getCategories(); // يجلب الفئات الثابتة والمخصصة
      _savedInvoices =
          await _dataSource.getAllInvoices(); // يجلب الفواتير المحفوظة
      emit(PosLoaded(
        items: _currentItems,
        total: _currentTotal,
        activeCategory: _activeCategory,
        categories: _allCategories, // يصدر القائمة الكاملة للفئات
      ));
    } catch (e) {
      emit(PosError("Failed to load initial data: $e"));
    }
  }

  void selectCategory(String categoryName) {
    if (state is PosLoaded) {
      _activeCategory = categoryName;
      final currentState = state as PosLoaded;
      emit(currentState.copyWith(activeCategory: _activeCategory));
    }
  }

  void addItem(String itemName, double unitPrice, int quantity) {
    _activeCategory = null;
    final cost = unitPrice * quantity;
    _currentItems.add(Item(
      id: _uuid.v4(),
      name: itemName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalCost: cost,
    ));
    _currentTotal += cost;

    if (state is PosLoaded) {
      final currentState = state as PosLoaded;
      emit(currentState.copyWith(
        items:
            List.from(_currentItems), // مهم: إصدار قائمة جديدة (Copy) لتحديث UI
        total: _currentTotal,
        activeCategory: _activeCategory,
      ));
    }
  }

  void removeItem(String itemId) {
    if (state is! PosLoaded) {
      return;
    }

    final currentState = state as PosLoaded;
    Item? itemToRemove;
    try {
      itemToRemove = _currentItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return;
    }

    _currentItems.removeWhere((item) => item.id == itemId);
    _currentTotal -= itemToRemove.totalCost;

    emit(currentState.copyWith(
      items: List.from(_currentItems),
      total: _currentTotal,
    ));
  }

  Future<void> finishOrder() async {
    if (state is! PosLoaded) {
      emit(PosError("Cannot finish order when POS is not loaded."));
      return;
    }

    final currentState = state as PosLoaded;
    emit(PosLoading());
    try {
      await CsvExporter.exportSales(_currentItems, _currentTotal);

      if (_currentItems.isNotEmpty) {
        final newInvoice = Invoice(
          id: _uuid.v4(),
          dateTime: DateTime.now(),
          items: List.from(_currentItems),
          total: _currentTotal,
        );
        await _dataSource.saveInvoice(newInvoice);
        _savedInvoices.add(newInvoice);
      }

      _currentItems.clear();
      _currentTotal = 0.0;
      _activeCategory = null;

      await loadInitialData();
    } catch (e) {
      emit(PosError("Failed to save order: $e"));
      emit(currentState.copyWith(
        items: List.from(_currentItems),
        total: _currentTotal,
        activeCategory: _activeCategory,
      ));
    }
  }

  void clearReceipt() {
    _currentItems.clear();
    _currentTotal = 0.0;
    if (state is PosLoaded) {
      final currentState = state as PosLoaded;
      emit(currentState.copyWith(
        items: List.from(_currentItems),
        total: _currentTotal,
      ));
    }
  }

  void resetActiveCategory() {
    if (state is PosLoaded) {
      _activeCategory = null;
      final currentState = state as PosLoaded;
      emit(currentState.copyWith(activeCategory: _activeCategory));
    }
  }

  Future<void> addOrUpdateUserCategory({
    String? id,
    required String name,
    required List<double> prices,
  }) async {
    if (state is! PosLoaded) {
      emit(PosError("Cannot add/update category when POS is not loaded."));
      return;
    }

    final currentState = state as PosLoaded;
    emit(PosLoading());
    try {
      List<Category> updatedUserDefinedCategories =
          _allCategories.where((cat) => cat.isUserDefined).toList();

      Category? existingCategory;
      if (id != null) {
        try {
          existingCategory = updatedUserDefinedCategories.firstWhere(
            (cat) => cat.id == id,
          );
        } catch (e) {
          existingCategory = null;
        }
      }

      if (existingCategory != null) {
        final int index =
            updatedUserDefinedCategories.indexOf(existingCategory);
        updatedUserDefinedCategories[index] =
            existingCategory.copyWith(name: name, prices: prices);
      } else {
        final newCategory = Category(
          id: _uuid.v4(),
          name: name,
          prices: prices,
          isUserDefined: true,
        );
        updatedUserDefinedCategories.add(newCategory);
      }

      await _dataSource.saveUserDefinedCategories(updatedUserDefinedCategories);
      _allCategories =
          await _dataSource.getCategories(); // تحديث الفئات بالكامل

      emit(currentState.copyWith(
        categories: _allCategories, // إصدار القائمة المحدثة
        activeCategory: _activeCategory,
      ));
    } catch (e) {
      emit(PosError("Failed to add/update category: $e"));
      emit(currentState.copyWith(
        categories: _allCategories,
        activeCategory: _activeCategory,
      ));
    }
  }

  Future<void> deleteUserCategory(String id) async {
    if (state is! PosLoaded) {
      emit(PosError("Cannot delete category when POS is not loaded."));
      return;
    }

    final currentState = state as PosLoaded;
    emit(PosLoading());
    try {
      List<Category> updatedUserDefinedCategories =
          _allCategories.where((cat) => cat.isUserDefined).toList();

      updatedUserDefinedCategories.removeWhere((cat) => cat.id == id);

      await _dataSource.saveUserDefinedCategories(updatedUserDefinedCategories);
      _allCategories =
          await _dataSource.getCategories(); // تحديث الفئات بالكامل

      if (_activeCategory != null) {
        final bool activeCategoryExists =
            _allCategories.any((cat) => cat.name == _activeCategory);
        if (!activeCategoryExists) {
          _activeCategory = null;
        }
      }

      emit(currentState.copyWith(
        categories: _allCategories, // إصدار القائمة المحدثة
        activeCategory: _activeCategory,
      ));
    } catch (e) {
      emit(PosError("Failed to delete category: $e"));
      emit(currentState.copyWith(
        categories: _allCategories,
        activeCategory: _activeCategory,
      ));
    }
  }

  Future<List<Invoice>> getSavedInvoices() async {
    _savedInvoices = await _dataSource.getAllInvoices();
    return List.from(_savedInvoices);
  }

  Future<void> clearAllSavedInvoices() async {
    await _dataSource.clearAllInvoices();
    _savedInvoices.clear();
    if (state is PosLoaded) {
      final currentState = state as PosLoaded;
      emit(currentState.copyWith(
        items: List.from(_currentItems),
        total: _currentTotal,
      ));
    }
  }
}
