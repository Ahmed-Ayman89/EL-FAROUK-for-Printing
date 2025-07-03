import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/app_constants.dart';
import '../../../core/models/category.dart';
import '../../../core/models/invoice.dart';
import '../../../core/database/database_helper.dart';

class PosDataSource {
  static const String _userDefinedCategoriesKey = 'user_defined_categories';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Category>> getCategories() async {
    final List<Category> allCategories = [];

    AppConstants.categoriesData.entries.forEach((entry) {
      allCategories.add(Category(
        id: entry.key,
        name: entry.key,
        prices: entry.value,
        isUserDefined: false,
      ));
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userCategoriesJson =
          prefs.getString(_userDefinedCategoriesKey);

      if (userCategoriesJson != null) {
        final List<dynamic> jsonList = jsonDecode(userCategoriesJson);
        final List<Category> userDefinedCategories =
            jsonList.map((json) => Category.fromJson(json)).toList();
        allCategories.addAll(userDefinedCategories);
      }
    } catch (e) {
      print("Error loading user-defined categories: $e");
    }

    return allCategories;
  }

  Future<void> saveUserDefinedCategories(List<Category> categories) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Category> userDefined =
        categories.where((cat) => cat.isUserDefined).toList();
    final List<Map<String, dynamic>> jsonList =
        userDefined.map((category) => category.toJson()).toList();
    await prefs.setString(_userDefinedCategoriesKey, jsonEncode(jsonList));
  }

  Future<void> saveInvoice(Invoice invoice) async {
    await _dbHelper.insertInvoice(invoice);
  }

  Future<List<Invoice>> getAllInvoices() async {
    return await _dbHelper.getInvoices();
  }

  Future<void> clearAllInvoices() async {
    await _dbHelper.clearAllInvoices();
  }
}
