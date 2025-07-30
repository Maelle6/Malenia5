import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/payslip_model.dart';

Future<void> generatePayslipPDF(PayslipModel payslip) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('🧾 Payslip - ${payslip.month}',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('👤 Employee Name: ${payslip.employeeName}'),
            pw.Text('💼 Position: ${payslip.position}'),
            pw.Text('🕓 Work Hours: ${payslip.totalWorkHours}'),
            pw.Divider(),
            pw.Text(
                '💰 Basic Salary: \$${payslip.basicSalary.toStringAsFixed(2)}'),
            pw.Text('🎁 Allowance: \$${payslip.allowance.toStringAsFixed(2)}'),
            pw.Text(
                '📉 Deductions: \$${payslip.deductions.toStringAsFixed(2)}'),
            pw.Divider(),
            pw.Text('🧮 Net Pay: \$${payslip.netPay.toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}
