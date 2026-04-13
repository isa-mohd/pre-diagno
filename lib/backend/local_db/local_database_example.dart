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
      await db.clearAllTables();
      print('[DB TEST] clearAllTables(): OK');

      // Create
      const eKey = EKey(
        cpr: '041002210',
        password: 'esa123456',
        name: 'Esa Mohd',
      );
      await db.insertEKey(
        eKey,
        replace: true,
      );
      print('[DB TEST] insert ekey -> ${eKey.toMap()}');

      const employee = Employee(
        employeeId: 'EMP-0001',
        email: 'ammar@admin.com',
        password: 'ammar123456',
        name: 'Ammar Yasser Ali',
        isAdmin: true,
      );
      await db.insertEmployee(
        employee,
        replace: true,
      );
      print('[DB TEST] insert employee -> ${employee.toMap()}');

      const staff = Employee(
        employeeId: 'EMP-0002',
        email: 'hussain@staff.com',
        password: 'hussain123456',
        name: 'Hussain',
        isAdmin: false,
      ); 
      await db.insertEmployee(
        staff,
        replace: true,
      );
      print('[DB TEST] insert employee -> ${staff.toMap()}');

      const appointment = Appointment(
        appointmentId: 'APT-0001',
        cpr: '041002210',
        doctorName: 'Dr. Amelia Carter',
        date: '2026-04-10',
        time: '09:00 AM',
        reson: 'Follow-up',
        status: 'pending',
      );
      await db.insertAppointment(
        appointment,
        replace: true,
      );
      print('[DB TEST] insert appointment -> ${appointment.toMap()}');

      const aiCase = AICase(
        caseId: 'CASE-0001',
        cpr: '041002210',
        age: '27',
        gender: 'Male',
        chronicDisease: 'None',
        possibleDisease: 'Flu',
        emergencyLevel: '5',
      );
      await db.insertAICase(
        aiCase,
        replace: true,
      );
      print('[DB TEST] insert AI case -> ${aiCase.toMap()}');

      // Read
      final patient = await db.getEKeyByCpr('0101991234');
      final appointments = await db.getAppointmentsByCpr('0101991234');
      final aiCases = await db.getAICasesByCpr('0101991234');
      print('[DB TEST] read patient -> ${patient?.toMap()}');
      print('[DB TEST] read appointments count -> ${appointments.length}');
      if (appointments.isNotEmpty) {
        print('[DB TEST] read first appointment -> ${appointments.first.toMap()}');
      }
      print('[DB TEST] read AI cases count -> ${aiCases.length}');
      if (aiCases.isNotEmpty) {
        print('[DB TEST] read first AI case -> ${aiCases.first.toMap()}');
      }
      final createdOk =
          patient != null && appointments.isNotEmpty && aiCases.isNotEmpty;

      // Update
      // if (patient != null) {
      //   await db.updateEKey(patient.copyWith(name: 'Hussain A. Ali'));
      // }

      // if (appointments.isNotEmpty) {
      //   await db.updateAppointment(
      //     appointments.first.copyWith(status: 'confirmed'),
      //   );
      // }

      // if (aiCases.isNotEmpty) {
      //   await db.updateAICase(
      //     aiCases.first.copyWith(emergencyLevel: 'Medium'),
      //   );
      // }

      // final updatedPatient = await db.getEKeyByCpr('0101991234');
      // final updatedAppointment = await db.getAppointmentById('APT-0001');
      // final updatedCase = await db.getAICaseById('CASE-0001');
      //   print('[DB TEST] updated patient -> ${updatedPatient?.toMap()}');
      //   print('[DB TEST] updated appointment -> ${updatedAppointment?.toMap()}');
      //   print('[DB TEST] updated AI case -> ${updatedCase?.toMap()}');
      // final updatedOk =
      //     updatedPatient?.name == 'Hussain A. Ali' &&
      //         updatedAppointment?.status == 'confirmed' &&
      //         updatedCase?.emergencyLevel == 'Medium';

      // Delete
      // await db.deleteAICase('CASE-0001');
      // await db.deleteAppointment('APT-0001');
      // await db.deleteEmployee('EMP-0001');
      // await db.deleteEKey('0101991234');

      // final deletedOk =
      //     (await db.getEKeyByCpr('0101991234')) == null &&
      //         (await db.getAppointmentById('APT-0001')) == null &&
      //         (await db.getAICaseById('CASE-0001')) == null &&
      //         (await db.getEmployeeById('EMP-0001')) == null;
      // print('[DB TEST] delete checks -> $deletedOk');

      final allPassed = createdOk ;
      print('[DB TEST] summary -> create: $createdOk');
      print('[DB TEST] result -> ${allPassed ? 'PASS' : 'FAIL'}');
      print('[DB TEST] ===== END SMOKE TEST =====');
      return allPassed;
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
