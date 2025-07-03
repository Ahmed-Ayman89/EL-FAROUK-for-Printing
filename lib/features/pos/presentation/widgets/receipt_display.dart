import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_styles.dart';
import '../../../../core/models/item.dart';
import '../../cubit/pos_cubit.dart';

class ReceiptDisplay extends StatelessWidget {
  final List<Item> items;

  const ReceiptDisplay({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightReceiptHeader
            : AppColors.darkReceiptHeader,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightReceiptHeader
              : AppColors.darkReceiptHeader,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightReceiptHeader
                  : AppColors.darkReceiptHeader,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("السعر",
                      style: AppStyles.receiptFont, textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text("الكمية",
                      style: AppStyles.receiptFont,
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 4,
                  child: Text("النوع",
                      style: AppStyles.receiptFont, textAlign: TextAlign.left),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final String itemIdToPass = item.id; // Capture the ID here

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightReceiptRow
                        : AppColors.darkReceiptRow,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.totalCost.toStringAsFixed(2),
                          style: AppStyles.receiptFont,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.quantity.toString(),
                          style: AppStyles.receiptFont,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.name,
                          style: AppStyles.receiptFont,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<PosCubit>().removeItem(itemIdToPass);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
