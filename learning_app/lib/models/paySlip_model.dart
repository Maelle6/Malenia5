class PayslipModel {
  final String employeeName;
  final String position;
  final double basicSalary;
  final double allowance;
  final double deductions;
  final int totalWorkHours;
  final String month;
  final double netPay;

  PayslipModel({
    required this.employeeName,
    required this.position,
    required this.basicSalary,
    required this.allowance,
    required this.deductions,
    required this.totalWorkHours,
    required this.month,
  }) : netPay = basicSalary + allowance - deductions;

  Map<String, dynamic> toMap() {
    return {
      'employeeName': employeeName,
      'position': position,
      'basicSalary': basicSalary,
      'allowance': allowance,
      'deductions': deductions,
      'totalWorkHours': totalWorkHours,
      'month': month,
      'netPay': netPay,
    };
  }

  factory PayslipModel.fromMap(Map<String, dynamic> map) {
    return PayslipModel(
      employeeName: map['employeeName'],
      position: map['position'],
      basicSalary: map['basicSalary'],
      allowance: map['allowance'],
      deductions: map['deductions'],
      totalWorkHours: map['totalWorkHours'],
      month: map['month'],
    );
  }
}
