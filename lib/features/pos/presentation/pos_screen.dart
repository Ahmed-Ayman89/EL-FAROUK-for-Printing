import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_styles.dart';
import '../cubit/pos_cubit.dart';
import '../cubit/pos_state.dart';
import 'widgets/category_buttons.dart';
import 'widgets/manage_categories_dialog.dart';
import 'widgets/price_buttons.dart';
import 'widgets/receipt_display.dart';
import 'widgets/total_section.dart';
import 'invoices_screen.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<PosCubit, PosState>(
        listener: (context, state) {
          if (state is PosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PosLoaded) {
            final allDisplayCategories = state.categories;

            return Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "EL-FAROUK",
                        style: AppStyles.titleFont
                            .copyWith(color: AppColors.goldenYellow),
                      ),
                      const SizedBox(height: 20),

                      // Manual Refresh Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<PosCubit>().loadInitialData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("تم تحديث البيانات")),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text("تحديث البيانات",
                                style: AppStyles.mainButtonFont),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Button to manage custom services (opens dialog)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => ManageCategoriesDialog(
                                  allCategories: state.categories,
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: Text("إدارة الخدمات والأسعار المخصصة",
                                style: AppStyles.mainButtonFont),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Button to view saved invoices
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const InvoicesScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: Text("عرض الفواتير المحفوظة",
                                style: AppStyles.mainButtonFont),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Category Buttons
                      CategoryButtons(
                        categories: allDisplayCategories,
                        activeCategory: state.activeCategory,
                        onCategorySelected: (categoryName) {
                          context.read<PosCubit>().selectCategory(categoryName);
                        },
                        onCustomPriceSelected: () {
                          _showCustomPriceDialog(context);
                          context.read<PosCubit>().selectCategory("خدمة مخصصة");
                        },
                        forceVerticalLayout: true,
                      ),

                      // Conditional Price Buttons Display (shows only if a category is active and not custom price)
                      if (state.activeCategory != null &&
                          state.activeCategory != "خدمة مخصصة")
                        Column(
                          children: [
                            const SizedBox(height: 15),
                            Text(
                              "أسعار ${state.activeCategory}:",
                              style: AppStyles.mainButtonFont
                                  .copyWith(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            PriceButtons(
                              categoryName: state.activeCategory,
                              onPriceSelected: (itemName, price) {
                                // <<<  هنا يتم استدعاء دالة إظهار نافذة الكمية  >>>
                                _showQuantityDialog(context, itemName, price);
                              },
                              categoriesData: {
                                for (var cat in state.categories)
                                  cat.name: cat.prices
                              },
                              priceButtonColor: AppColors.errorRed,
                            ),
                          ],
                        ),

                      const SizedBox(height: 15),

                      SizedBox(
                        height: 300,
                        child: ReceiptDisplay(items: state.items),
                      ),
                      const SizedBox(height: 15),

                      TotalSection(
                        total: state.total,
                        onFinishOrder: () =>
                            context.read<PosCubit>().finishOrder(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is PosLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text("Initializing POS system..."));
        },
      ),
    );
  }

  // دالة مساعدة لإظهار نافذة الكمية (بها استدعاء addItem)
  void _showQuantityDialog(
      BuildContext context, String itemName, double price) {
    final TextEditingController qtyController =
        TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("ادخل الكمية", style: AppStyles.mainButtonFont),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppStyles.mainButtonFont,
            decoration: const InputDecoration(hintText: "الكمية"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("إضافة", style: AppStyles.mainButtonFont),
              onPressed: () {
                final qty = int.tryParse(qtyController.text) ?? 1;
                if (qty > 0) {
                  // <<<  هنا يتم استدعاء دالة addItem في الكيوبت  >>>
                  context.read<PosCubit>().addItem(itemName, price, qty);
                  Navigator.of(dialogContext)
                      .pop(); // إغلاق النافذة بعد الإضافة
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                        content: Text("الكمية يجب أن تكون أكبر من صفر")),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      context.read<PosCubit>().resetActiveCategory();
    });
  }

  // دالة مساعدة لإظهار نافذة السعر المخصص
  void _showCustomPriceDialog(BuildContext context) {
    final TextEditingController priceController = TextEditingController();
    final TextEditingController qtyController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("سعر مخصص", style: AppStyles.mainButtonFont),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppStyles.mainButtonFont,
                decoration: const InputDecoration(hintText: "السعر"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppStyles.mainButtonFont,
                decoration: const InputDecoration(hintText: "الكمية"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("إضافة", style: AppStyles.mainButtonFont),
              onPressed: () {
                final price = double.tryParse(priceController.text);
                final qty = int.tryParse(qtyController.text) ?? 1;

                if (price != null && price > 0 && qty > 0) {
                  context.read<PosCubit>().addItem("خدمة مخصصة", price, qty);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text("يرجى إدخال سعر وكمية صحيحة")),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      context.read<PosCubit>().resetActiveCategory();
    });
  }
}
