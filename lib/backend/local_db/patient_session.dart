import 'package:shared_preferences/shared_preferences.dart';

import 'local_database.dart';

class PatientSessionService {
  PatientSessionService._();

  static const String _currentPatientCprKey = 'current_patient_cpr';

  static Future<void> setCurrentPatientCpr(String cpr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPatientCprKey, cpr.trim());
  }

  static Future<String?> getCurrentPatientCpr() async {
    final prefs = await SharedPreferences.getInstance();
    final cpr = prefs.getString(_currentPatientCprKey)?.trim();
    if (cpr == null || cpr.isEmpty) {
      return null;
    }
    return cpr;
  }

  static Future<EKey?> getCurrentPatient() async {
    final cpr = await getCurrentPatientCpr();
    if (cpr == null) {
      return null;
    }
    return LocalDatabaseService.instance.getEKeyByCpr(cpr);
  }

  static String resolvePatientEmail(EKey patient) {
    final email = patient.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return '${patient.cpr}@ekey.com';
  }

  static Future<void> clearCurrentPatient() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentPatientCprKey);
  }
}
