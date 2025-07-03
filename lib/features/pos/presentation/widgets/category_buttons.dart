import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_styles.dart';
import '../../../../core/models/category.dart';

class CategoryButtons extends StatelessWidget {
  final List<Category> categories; // هذه القائمة ستحتوي الآن على كل الفئات
  final String? activeCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onCustomPriceSelected;
  final bool forceVerticalLayout;

  const CategoryButtons({
    super.key,
    required this.categories,
    this.activeCategory,
    required this.onCategorySelected,
    required this.onCustomPriceSelected,
    this.forceVerticalLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...categories.map((category) {
          // نمر على كل الفئات
          final bool isActive = activeCategory == category.name;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onCategorySelected(category.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? AppColors.activeGreen
                      : (category.isUserDefined
                          ? Colors.deepPurple // لون مميز للخدمات المضافة
                          : Theme.of(context).buttonTheme.colorScheme?.primary),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: AppStyles.mainButtonFont,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(category.name),
              ),
            ),
          );
        }).toList(),
        // زر الخدمة المخصصة (سعر يدوي) يظل في مكانه كخيار مستقل
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCustomPriceSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                textStyle: AppStyles.mainButtonFont,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("خدمة مخصصة (سعر يدوي)"), // تغيير النص للتوضيح
            ),
          ),
        ),
      ],
    );
  }
}
