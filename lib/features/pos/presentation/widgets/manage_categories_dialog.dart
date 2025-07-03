import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_styles.dart';
import '../../../../core/models/category.dart';
import '../../cubit/pos_cubit.dart';

class ManageCategoriesDialog extends StatefulWidget {
  final List<Category> allCategories; // تستقبل كل الفئات

  const ManageCategoriesDialog({super.key, required this.allCategories});

  @override
  State<ManageCategoriesDialog> createState() => _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<ManageCategoriesDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pricesController = TextEditingController();
  String? _editingCategoryId; // لتتبع الفئة التي يتم تعديلها

  @override
  Widget build(BuildContext context) {
    // فلترة الفئات المعرفة من المستخدم فقط للعرض في القائمة
    final List<Category> userDefinedCategories =
        widget.allCategories.where((cat) => cat.isUserDefined).toList();

    return AlertDialog(
      title: Text("إدارة الخدمات والأسعار", style: AppStyles.mainButtonFont),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "اسم الخدمة"),
                style: AppStyles.receiptFont,
              ),
              TextField(
                controller: _pricesController,
                decoration: const InputDecoration(
                    labelText: "الأسعار (أرقام مفصولة بفاصلة ,)"),
                keyboardType: TextInputType.text,
                style: AppStyles.receiptFont,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _addOrUpdateCategory(context);
                    },
                    child: Text(
                        _editingCategoryId == null
                            ? "إضافة خدمة"
                            : "تعديل خدمة",
                        style: AppStyles.receiptFont),
                  ),
                  if (_editingCategoryId != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextButton(
                        onPressed: _clearEditing,
                        child:
                            Text("إلغاء التعديل", style: AppStyles.receiptFont),
                      ),
                    ),
                ],
              ),
              const Divider(),
              if (userDefinedCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "لا توجد خدمات مخصصة حالياً.",
                    style: AppStyles.receiptFont.copyWith(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userDefinedCategories.length,
                  itemBuilder: (context, index) {
                    final category = userDefinedCategories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: AppStyles.mainButtonFont,
                                  ),
                                  Text(
                                    "الأسعار: ${category.prices.map((p) => p.toStringAsFixed(2)).join(', ')}",
                                    style: AppStyles.receiptFont
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _startEditing(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(context, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("إغلاق", style: AppStyles.mainButtonFont),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _addOrUpdateCategory(BuildContext context) {
    final name = _nameController.text.trim();
    final pricesString = _pricesController.text.trim();

    if (name.isEmpty || pricesString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال اسم الخدمة والأسعار.")),
      );
      return;
    }

    try {
      final prices = pricesString
          .split(',')
          .map((s) => double.tryParse(s.trim()))
          .where((p) => p != null)
          .cast<double>()
          .toList();

      if (prices.isEmpty || prices.any((p) => p <= 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("الأسعار يجب أن تكون أرقامًا موجبة وغير فارغة.")),
        );
        return;
      }

      context.read<PosCubit>().addOrUpdateUserCategory(
            id: _editingCategoryId,
            name: name,
            prices: prices,
          );
      _clearEditing();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تنسيق الأسعار: $e")),
      );
    }
  }

  void _startEditing(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _pricesController.text =
          category.prices.map((p) => p.toStringAsFixed(2)).join(', ');
    });
  }

  void _clearEditing() {
    setState(() {
      _editingCategoryId = null;
      _nameController.clear();
      _pricesController.clear();
    });
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد من حذف الخدمة '${category.name}'؟"),
          actions: <Widget>[
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("حذف", style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<PosCubit>().deleteUserCategory(category.id);
                Navigator.of(dialogContext).pop();
                _clearEditing();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pricesController.dispose();
    super.dispose();
  }
}
