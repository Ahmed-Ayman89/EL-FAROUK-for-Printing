import 'package:flutter/material.dart';
import '../../../../config/app_styles.dart';

class PriceButtons extends StatelessWidget {
  final String? categoryName;
  final Function(String itemName, double price) onPriceSelected;
  final Map<String, List<double>> categoriesData;
  // تم إزالة forceVerticalLayout لأنه لم يعد مطلوبًا للتحكم في التخطيط هنا
  final Color? priceButtonColor;

  const PriceButtons({
    super.key,
    required this.categoryName,
    required this.onPriceSelected,
    required this.categoriesData,
    this.priceButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final prices = categoriesData[categoryName] ?? [];

    if (categoryName == null ||
        categoryName == "خدمة مخصصة" ||
        prices.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          categoryName == null
              ? "اختر فئة لعرض الأسعار"
              : categoryName == "خدمة مخصصة"
                  ? "ادخل السعر المخصص"
                  : "لا توجد أسعار لهذه الفئة",
          style: AppStyles.receiptFont.copyWith(color: Colors.grey),
        ),
      );
    }

    // هذا هو الجزء الوحيد الذي سيعرض أزرار الأسعار، وسيكون دائمًا أفقيًا باستخدام Wrap
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0, vertical: 5.0), // Padding حول مجموعة الأزرار
      child: Wrap(
        spacing: 10.0, // المسافة الأفقية بين الأزرار
        runSpacing:
            10.0, // المسافة الرأسية بين صفوف الأزرار (لو كانت الأزرار أكتر من سطر)
        alignment: WrapAlignment.center, // توسيط الأزرار لو لم تملأ العرض
        children: prices.map((price) {
          return ElevatedButton(
            onPressed: () => onPriceSelected(categoryName!, price),
            style: ElevatedButton.styleFrom(
              backgroundColor: priceButtonColor ??
                  Theme.of(context).buttonTheme.colorScheme!.primary,
              foregroundColor: Colors.white,
              textStyle: AppStyles.priceButtonFont,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text("${price.toStringAsFixed(2)} جنيه"),
          );
        }).toList(),
      ),
    );
  }
}
