import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_styles.dart';

class TotalSection extends StatelessWidget {
  final double total;
  final VoidCallback onFinishOrder;

  const TotalSection({
    super.key,
    required this.total,
    required this.onFinishOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightReceiptHeader
                : AppColors.darkReceiptHeader,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.money, size: 40, color: Colors.green),
              const SizedBox(width: 20),
              Text(
                "الإجمالي: ${total.toStringAsFixed(2)} جنيه",
                style: AppStyles.totalFont,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onFinishOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(55),
              textStyle: AppStyles.mainButtonFont,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text("إنهاء وحفظ الطلب"),
          ),
        ),
      ],
    );
  }
}
