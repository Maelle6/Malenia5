import '../models/payslip_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

PayslipModel generatePayslipFromData(Map<String, dynamic> emp, String month) {
  return PayslipModel(
    employeeName: emp['full_name'] ?? 'Unknown',
    position: emp['designation'] ?? 'Unknown',
    basicSalary: (emp['fixedSalary'] ?? 0).toDouble(),
    allowance: (emp['bonuses'] ?? 0).toDouble(),
    deductions: (emp['deductions'] ?? 0).toDouble(),
    totalWorkHours: (emp['workHours'] ?? 0).toInt(), // ✅ Fix here
    month: month,
  );
}

Future<void> storePayslip(
    PayslipModel payslip, String userId, String empId) async {
  final payslipRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('employees')
      .doc(empId)
      .collection('payslips')
      .doc(payslip.month);

  await payslipRef.set(payslip.toMap());
}
