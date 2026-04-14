import 'local_database.dart';

/// Example local DB flow for insert, query, update, and delete.
/// Call this from a debug button or startup routine when needed.
class LocalDatabaseExample {
  static Future<void> run() async {
    await runSmokeTest();
  }

  /// Returns true when create/read/update/delete checks all pass.
  static Future<bool> runSmokeTest() async {
    final db = LocalDatabaseService.instance;

    try {
      print('[DB TEST] ===== START SMOKE TEST =====');
      await db.initialize();
      print('[DB TEST] initialize(): OK');
      // await db.clearAllTables();
      // print('[DB TEST] clearAllTables(): OK');

      // Create
      const eKey = EKey(
        cpr: '040601463',
        password: 'ammar123',
        name: 'Ammar Yasser Abdulwahed',
      );
      await db.insertEKey(
        eKey,
        replace: true,
      );
      print('[DB TEST] insert ekey -> ${eKey.toMap()}');

      const employee = Employee(
        employeeId: 'EMP-0001',
        email: 'ehab@admin.com',
        password: 'ehab123',
        name: 'Ehab Juma Adwan',
        isAdmin: true,
      );
      await db.insertEmployee(
        employee,
        replace: true,
      );
      print('[DB TEST] insert employee -> ${employee.toMap()}');

      const staff1 = Employee(
        employeeId: 'EMP-0002',
        email: 'hussain@staff.com',
        password: 'hussain123',
        name: 'Hussain Abdulhasan',
        isAdmin: false,
      ); 
      await db.insertEmployee(
        staff1,
        replace: true,
      );
      print('[DB TEST] insert employee -> ${staff1.toMap()}');

      const staff2 = Employee(
        employeeId: 'EMP-0003',
        email: 'salman@staff.com',
        password: 'salman123',
        name: 'Salman sabah',
        isAdmin: false,
      ); 
      await db.insertEmployee(
        staff2,
        replace: true,
      );
      print('[DB TEST] insert employee -> ${staff2.toMap()}');

      return true;
    } on LocalDbException catch (e) {
      // Replace with logger/snackbar as needed.
      print('[DB TEST] LocalDbException: $e');
      if (e.cause != null) {
        print('[DB TEST] cause: ${e.cause}');
      }
      print('[DB TEST] ===== END SMOKE TEST (FAILED) =====');
      return false;
    }
  }
}
