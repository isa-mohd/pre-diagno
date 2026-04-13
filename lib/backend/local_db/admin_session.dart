import 'package:shared_preferences/shared_preferences.dart';

import 'local_database.dart';

class AdminSessionService {
  AdminSessionService._();

  static const String _currentEmployeeIdKey = 'current_employee_id';

  static Future<void> setCurrentEmployeeId(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentEmployeeIdKey, employeeId.trim());
  }

  static Future<String?> getCurrentEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString(_currentEmployeeIdKey)?.trim();
    if (employeeId == null || employeeId.isEmpty) {
      return null;
    }
    return employeeId;
  }

  static Future<Employee?> getCurrentEmployee() async {
    final employeeId = await getCurrentEmployeeId();
    if (employeeId == null) {
      return null;
    }
    return LocalDatabaseService.instance.getEmployeeById(employeeId);
  }

  static Future<void> clearCurrentEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentEmployeeIdKey);
  }
}
