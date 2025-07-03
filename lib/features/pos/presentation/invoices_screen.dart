import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_styles.dart';
import '../../../core/models/invoice.dart';
import '../../../core/utils/pdf_generator.dart';
import '../cubit/pos_cubit.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "الفواتير المحفوظة",
          style: AppStyles.titleFont.copyWith(color: AppColors.goldenYellow),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldenYellow),
      ),
      body: FutureBuilder<List<Invoice>>(
        future: context.read<PosCubit>().getSavedInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "لا توجد فواتير محفوظة حتى الآن.",
                style: AppStyles.mainButtonFont.copyWith(color: Colors.grey),
              ),
            );
          } else {
            final invoices = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  color: Theme.of(context).cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "فاتورة رقم: ${invoice.id.substring(0, 8)}...",
                          style: AppStyles.mainButtonFont.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenYellow,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.dateTime)}",
                          style: AppStyles.receiptFont
                              .copyWith(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "تفاصيل الطلب:",
                          style: AppStyles.receiptFont
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        ...invoice.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: AppStyles.receiptFont,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${item.quantity} x ${item.unitPrice.toStringAsFixed(2)} = ${item.totalCost.toStringAsFixed(2)}",
                                    style: AppStyles.receiptFont,
                                  ),
                                ],
                              ),
                            )),
                        const Divider(
                            height: 20, thickness: 1, color: Colors.grey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "الإجمالي الكلي:",
                              style: AppStyles.mainButtonFont.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorRed,
                              ),
                            ),
                            Text(
                              "${invoice.total.toStringAsFixed(2)} جنيه",
                              style: AppStyles.mainButtonFont.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Printing.layoutPdf(
                                onLayout: (format) =>
                                    PdfGenerator.generatePdfFromInvoice(format,
                                        invoice: invoice),
                              );
                            },
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: Text("طباعة الإيصال",
                                style: AppStyles.mainButtonFont
                                    .copyWith(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("تأكيد المسح"),
              content:
                  const Text("هل أنت متأكد من مسح جميع الفواتير المحفوظة؟"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text("إلغاء")),
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("مسح")),
              ],
            ),
          );
          if (confirm == true) {
            await context.read<PosCubit>().clearAllSavedInvoices();
            (context as Element).markNeedsBuild();
          }
        },
        backgroundColor: AppColors.errorRed,
        child: const Icon(Icons.delete_forever, color: Colors.white),
        tooltip: "مسح كل الفواتير",
      ),
    );
  }
}
