import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice.dart';

class PdfGenerator {
  static Future<Uint8List> generatePdfFromInvoice(
    PdfPageFormat format, {
    required Invoice invoice,
    double discount = 0.0,
    String? taxNumber, // الرقم الضريبي (اختياري)
  }) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/static/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final boldFontData = await rootBundle.load("assets/static/Cairo-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    const shopName = "EL-FAROUK for Printing";
    const shopPhone = "01272742485";
    const shopAddress = "شارع الجامعة، الزقازيق، الشرقيه";

    final discountedTotal = invoice.total - discount;

    // إعداد QR Code
    final qrContent = 'فاتورة رقم: ${invoice.id}\n'
        'الإجمالي: ${invoice.total.toStringAsFixed(2)} جنيه\n'
        'الخصم: ${discount.toStringAsFixed(2)} جنيه\n'
        'الصافي: ${discountedTotal.toStringAsFixed(2)} جنيه\n'
        'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.dateTime)}';

    final qrCode = Barcode.qrCode();
    final qrImage = qrCode.toSvg(qrContent, width: 120, height: 120);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(shopName,
                      style: pw.TextStyle(font: ttfBold, fontSize: 24)),
                  pw.SizedBox(height: 8),
                  pw.Text(shopPhone,
                      style: pw.TextStyle(font: ttf, fontSize: 14)),
                  pw.Text(shopAddress,
                      style: pw.TextStyle(font: ttf, fontSize: 14)),
                  if (taxNumber != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text("الرقم الضريبي: $taxNumber",
                        style: pw.TextStyle(font: ttf, fontSize: 13)),
                  ],
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 16),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("رقم الفاتورة: ${invoice.id}",
                          style: pw.TextStyle(font: ttf, fontSize: 14)),
                      pw.Text(
                          "التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.dateTime)}",
                          style: pw.TextStyle(font: ttf, fontSize: 14)),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // جدول الأصناف
                  pw.Table.fromTextArray(
                    headers: ['الصنف', 'الكمية', 'سعر الوحدة', 'الإجمالي'],
                    data: invoice.items.map((item) {
                      return [
                        item.name,
                        item.quantity.toString(),
                        item.unitPrice.toStringAsFixed(2),
                        item.totalCost.toStringAsFixed(2),
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(font: ttfBold, fontSize: 13),
                    cellStyle: pw.TextStyle(font: ttf, fontSize: 12),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    border: pw.TableBorder.all(
                        color: PdfColors.grey700, width: 0.75),
                    cellAlignment: pw.Alignment.center,
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                    },
                  ),

                  pw.SizedBox(height: 16),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الإجمالي:",
                          style: pw.TextStyle(font: ttfBold, fontSize: 15)),
                      pw.Text("${invoice.total.toStringAsFixed(2)} جنيه",
                          style: pw.TextStyle(font: ttf, fontSize: 15)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الخصم:",
                          style: pw.TextStyle(font: ttf, fontSize: 14)),
                      pw.Text("${discount.toStringAsFixed(2)} جنيه",
                          style: pw.TextStyle(font: ttf, fontSize: 14)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الصافي:",
                          style: pw.TextStyle(font: ttfBold, fontSize: 16)),
                      pw.Text("${discountedTotal.toStringAsFixed(2)} جنيه",
                          style: pw.TextStyle(font: ttf, fontSize: 16)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1),
                  pw.Text("شكراً لتعاملكم معنا!",
                      style: pw.TextStyle(font: ttf, fontSize: 14)),

                  pw.SizedBox(height: 16),

                  // عرض QR Code
                  pw.Container(
                    width: 120,
                    height: 120,
                    child: pw.SvgImage(svg: qrImage),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
