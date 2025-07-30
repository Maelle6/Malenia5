
class Employee {
  String id;
  String fullName;
  String designation;
  String salaryType;
  double hourlyRate;
  double fixedSalary;
  double workHours;
  double bonuses;
  double deductions;
  String month;
  int year;

  Employee({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.salaryType,
    required this.hourlyRate,
    required this.fixedSalary,
    required this.workHours,
    required this.bonuses,
    required this.deductions,
    required this.month,
    required this.year,
  });

  factory Employee.fromMap(Map<String, dynamic> data, String id) {
    return Employee(
      id: id,
      fullName: data['full_name'],
      designation: data['designation'],
      salaryType: data['salaryType'],
      hourlyRate: data['hourlyRate']?.toDouble() ?? 0,
      fixedSalary: data['fixedSalary']?.toDouble() ?? 0,
      workHours: data['workHours']?.toDouble() ?? 0,
      bonuses: data['bonuses']?.toDouble() ?? 0,
      deductions: data['deductions']?.toDouble() ?? 0,
      month: data['month'],
      year: data['year'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'designation': designation,
      'salaryType': salaryType,
      'hourlyRate': hourlyRate,
      'fixedSalary': fixedSalary,
      'workHours': workHours,
      'bonuses': bonuses,
      'deductions': deductions,
      'month': month,
      'year': year,
    };
  }
}
