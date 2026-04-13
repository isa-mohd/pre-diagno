import 'dart:async';

import 'package:sqflite/sqflite.dart';

class LocalDbException implements Exception {
  const LocalDbException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'LocalDbException: $message';
}

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService instance = LocalDatabaseService._();

  static const String _dbName = 'prediagno_local.db';
  static const int _dbVersion = 2;

  static const String tableEkey = 'ekey';
  static const String tableEmployee = 'employee';
  static const String tableAppointment = 'appointment';
  static const String tableAiCases = 'AI_cases';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    await database;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_dbName';

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE $tableEkey (
          cpr TEXT PRIMARY KEY,
          password TEXT,
          name TEXT,
          email TEXT
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableEmployee (
          employee_id TEXT PRIMARY KEY unique,
          email TEXT,
          password TEXT,
          name TEXT,
          IsAdmin INTEGER CHECK (IsAdmin IN (0, 1))
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableAppointment (
          appointment_id TEXT PRIMARY KEY,
          cpr TEXT,
          Doctor_name TEXT,
          date TEXT,
          time TEXT,
          reson TEXT,
          status TEXT,
          FOREIGN KEY (cpr) REFERENCES $tableEkey(cpr) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE $tableAiCases (
          case_id TEXT PRIMARY KEY,
          cpr TEXT,
          age TEXT,
          gender TEXT,
          chronic_disease TEXT,
          possible_disease TEXT,
          emergency_level TEXT,
          FOREIGN KEY (cpr) REFERENCES $tableEkey(cpr) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // Helpful indexes for common lookups in mobile flows.
      await txn.execute(
        'CREATE INDEX idx_appointment_cpr ON $tableAppointment(cpr)',
      );
      await txn.execute(
        'CREATE INDEX idx_ai_cases_cpr ON $tableAiCases(cpr)',
      );
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableEkey ADD COLUMN email TEXT');
    }
  }

  Future<T> _run<T>(String op, Future<T> Function(Database db) action) async {
    try {
      final db = await database;
      return await action(db);
    } on DatabaseException catch (e, st) {
      throw LocalDbException('Database operation failed: $op',
          cause: e, stackTrace: st);
    } catch (e, st) {
      throw LocalDbException('Unexpected failure during: $op',
          cause: e, stackTrace: st);
    }
  }

  // ----------------------------
  // ekey table CRUD
  // ----------------------------

  Future<void> insertEKey(EKey row, {bool replace = false}) async {
    await _run('insert ekey', (db) async {
      await db.insert(
        tableEkey,
        row.toMap(),
        conflictAlgorithm:
            replace ? ConflictAlgorithm.replace : ConflictAlgorithm.abort,
      );
    });
  }

  Future<EKey?> getEKeyByCpr(String cpr) async {
    return _run('get ekey by cpr', (db) async {
      final rows = await db.query(
        tableEkey,
        where: 'cpr = ?',
        whereArgs: [cpr],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return EKey.fromMap(rows.first);
    });
  }

  Future<List<EKey>> getAllEKeys() async {
    return _run('get all ekey rows', (db) async {
      final rows = await db.query(tableEkey, orderBy: 'name COLLATE NOCASE');
      return rows.map(EKey.fromMap).toList();
    });
  }

  Future<int> updateEKey(EKey row) async {
    return _run('update ekey', (db) {
      return db.update(
        tableEkey,
        row.toMap(),
        where: 'cpr = ?',
        whereArgs: [row.cpr],
      );
    });
  }

  Future<int> deleteEKey(String cpr) async {
    return _run('delete ekey', (db) {
      return db.delete(
        tableEkey,
        where: 'cpr = ?',
        whereArgs: [cpr],
      );
    });
  }

  // ----------------------------
  // employee table CRUD
  // ----------------------------

  Future<void> insertEmployee(Employee row, {bool replace = false}) async {
    await _run('insert employee', (db) async {
      await db.insert(
        tableEmployee,
        row.toMap(),
        conflictAlgorithm:
            replace ? ConflictAlgorithm.replace : ConflictAlgorithm.abort,
      );
    });
  }

  Future<Employee?> getEmployeeById(String employeeId) async {
    return _run('get employee by id', (db) async {
      final rows = await db.query(
        tableEmployee,
        where: 'employee_id = ?',
        whereArgs: [employeeId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Employee.fromMap(rows.first);
    });
  }

  Future<Employee?> getEmployeeByEmailAndRole(
    String email, {
    required bool isAdmin,
  }) async {
    return _run('get employee by email and role', (db) async {
      final normalizedEmail = email.trim().toLowerCase();
      final rows = await db.query(
        tableEmployee,
        where: 'LOWER(email) = ? AND IsAdmin = ?',
        whereArgs: [normalizedEmail, isAdmin ? 1 : 0],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Employee.fromMap(rows.first);
    });
  }

  Future<List<Employee>> getAllEmployees() async {
    return _run('get all employees', (db) async {
      final rows =
          await db.query(tableEmployee, orderBy: 'name COLLATE NOCASE');
      return rows.map(Employee.fromMap).toList();
    });
  }

  Future<int> updateEmployee(Employee row) async {
    return _run('update employee', (db) {
      return db.update(
        tableEmployee,
        row.toMap(),
        where: 'employee_id = ?',
        whereArgs: [row.employeeId],
      );
    });
  }

  Future<int> deleteEmployee(String employeeId) async {
    return _run('delete employee', (db) {
      return db.delete(
        tableEmployee,
        where: 'employee_id = ?',
        whereArgs: [employeeId],
      );
    });
  }

  Future<int> countEmployeesByRole({required bool isAdmin}) async {
    return _run('count employees by role', (db) async {
      final result = await db.rawQuery(
        'SELECT COUNT(*) AS total FROM $tableEmployee WHERE IsAdmin = ?',
        [isAdmin ? 1 : 0],
      );
      return (result.first['total'] as int?) ?? 0;
    });
  }

  // ----------------------------
  // appointment table CRUD
  // ----------------------------

  Future<void> insertAppointment(Appointment row,
      {bool replace = false}) async {
    await _run('insert appointment', (db) async {
      await db.insert(
        tableAppointment,
        row.toMap(),
        conflictAlgorithm:
            replace ? ConflictAlgorithm.replace : ConflictAlgorithm.abort,
      );
    });
  }

  Future<Appointment?> getAppointmentById(String appointmentId) async {
    return _run('get appointment by id', (db) async {
      final rows = await db.query(
        tableAppointment,
        where: 'appointment_id = ?',
        whereArgs: [appointmentId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Appointment.fromMap(rows.first);
    });
  }

  Future<List<Appointment>> getAppointmentsByCpr(String cpr) async {
    return _run('get appointments by cpr', (db) async {
      final rows = await db.query(
        tableAppointment,
        where: 'cpr = ?',
        whereArgs: [cpr],
        orderBy: 'date ASC, time ASC',
      );
      return rows.map(Appointment.fromMap).toList();
    });
  }

  Future<List<Appointment>> getAllAppointments() async {
    return _run('get all appointments', (db) async {
      final rows =
          await db.query(tableAppointment, orderBy: 'date ASC, time ASC');
      return rows.map(Appointment.fromMap).toList();
    });
  }

  Future<int> countAppointments() async {
    return _run('count appointments', (db) async {
      final result =
          await db.rawQuery('SELECT COUNT(*) AS total FROM $tableAppointment');
      return (result.first['total'] as int?) ?? 0;
    });
  }

  Future<int> updateAppointment(Appointment row) async {
    return _run('update appointment', (db) {
      return db.update(
        tableAppointment,
        row.toMap(),
        where: 'appointment_id = ?',
        whereArgs: [row.appointmentId],
      );
    });
  }

  Future<int> deleteAppointment(String appointmentId) async {
    return _run('delete appointment', (db) {
      return db.delete(
        tableAppointment,
        where: 'appointment_id = ?',
        whereArgs: [appointmentId],
      );
    });
  }

  // ----------------------------
  // AI_cases table CRUD
  // ----------------------------

  Future<void> insertAICase(AICase row, {bool replace = false}) async {
    await _run('insert AI case', (db) async {
      await db.insert(
        tableAiCases,
        row.toMap(),
        conflictAlgorithm:
            replace ? ConflictAlgorithm.replace : ConflictAlgorithm.abort,
      );
    });
  }

  Future<AICase?> getAICaseById(String caseId) async {
    return _run('get AI case by id', (db) async {
      final rows = await db.query(
        tableAiCases,
        where: 'case_id = ?',
        whereArgs: [caseId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return AICase.fromMap(rows.first);
    });
  }

  Future<List<AICase>> getAICasesByCpr(String cpr) async {
    return _run('get AI cases by cpr', (db) async {
      final rows = await db.query(
        tableAiCases,
        where: 'cpr = ?',
        whereArgs: [cpr],
      );
      return rows.map(AICase.fromMap).toList();
    });
  }

  Future<List<AICase>> getAllAICases() async {
    return _run('get all AI cases', (db) async {
      final rows = await db.query(tableAiCases);
      return rows.map(AICase.fromMap).toList();
    });
  }

  Future<int> updateAICase(AICase row) async {
    return _run('update AI case', (db) {
      return db.update(
        tableAiCases,
        row.toMap(),
        where: 'case_id = ?',
        whereArgs: [row.caseId],
      );
    });
  }

  Future<int> deleteAICase(String caseId) async {
    return _run('delete AI case', (db) {
      return db.delete(
        tableAiCases,
        where: 'case_id = ?',
        whereArgs: [caseId],
      );
    });
  }

  Future<void> clearAllTables() async {
    await _run('clear all tables', (db) async {
      await db.transaction((txn) async {
        await txn.delete(tableAiCases);
        await txn.delete(tableAppointment);
        await txn.delete(tableEmployee);
        await txn.delete(tableEkey);
      });
    });
  }
}

class EKey {
  const EKey({
    required this.cpr,
    this.password,
    this.name,
    this.email,
  });

  final String cpr;
  final String? password;
  final String? name;
  final String? email;

  Map<String, dynamic> toMap() {
    return {
      'cpr': cpr,
      'password': password,
      'name': name,
      'email': email,
    };
  }

  factory EKey.fromMap(Map<String, dynamic> map) {
    return EKey(
      cpr: map['cpr'] as String,
      password: map['password'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
    );
  }

  EKey copyWith({
    String? cpr,
    String? password,
    String? name,
    String? email,
  }) {
    return EKey(
      cpr: cpr ?? this.cpr,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class Employee {
  const Employee({
    required this.employeeId,
    this.email,
    this.password,
    this.name,
    required this.isAdmin,
  });

  final String employeeId;
  final String? email;
  final String? password;
  final String? name;
  final bool isAdmin;

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'email': email,
      'password': password,
      'name': name,
      'IsAdmin': isAdmin ? 1 : 0,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employee_id'] as String,
      email: map['email'] as String?,
      password: map['password'] as String?,
      name: map['name'] as String?,
      isAdmin: (map['IsAdmin'] as num?) == 1,
    );
  }

  Employee copyWith({
    String? employeeId,
    String? email,
    String? password,
    String? name,
    bool? isAdmin,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class Appointment {
  const Appointment({
    required this.appointmentId,
    required this.cpr,
    this.doctorName,
    this.date,
    this.time,
    this.reson,
    this.status,
  });

  final String appointmentId;
  final String cpr;
  final String? doctorName;
  final String? date;
  final String? time;
  final String? reson;
  final String? status;

  Map<String, dynamic> toMap() {
    return {
      'appointment_id': appointmentId,
      'cpr': cpr,
      'Doctor_name': doctorName,
      'date': date,
      'time': time,
      'reson': reson,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointment_id'] as String,
      cpr: map['cpr'] as String,
      doctorName: map['Doctor_name'] as String?,
      date: map['date'] as String?,
      time: map['time'] as String?,
      reson: map['reson'] as String?,
      status: map['status'] as String?,
    );
  }

  Appointment copyWith({
    String? appointmentId,
    String? cpr,
    String? doctorName,
    String? date,
    String? time,
    String? reson,
    String? status,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      cpr: cpr ?? this.cpr,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      time: time ?? this.time,
      reson: reson ?? this.reson,
      status: status ?? this.status,
    );
  }
}

class AICase {
  const AICase({
    required this.caseId,
    required this.cpr,
    this.age,
    this.gender,
    this.chronicDisease,
    this.possibleDisease,
    this.emergencyLevel,
  });

  final String caseId;
  final String cpr;
  final String? age;
  final String? gender;
  final String? chronicDisease;
  final String? possibleDisease;
  final String? emergencyLevel;

  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'cpr': cpr,
      'age': age,
      'gender': gender,
      'chronic_disease': chronicDisease,
      'possible_disease': possibleDisease,
      'emergency_level': emergencyLevel,
    };
  }

  factory AICase.fromMap(Map<String, dynamic> map) {
    return AICase(
      caseId: map['case_id'] as String,
      cpr: map['cpr'] as String,
      age: map['age'] as String?,
      gender: map['gender'] as String?,
      chronicDisease: map['chronic_disease'] as String?,
      possibleDisease: map['possible_disease'] as String?,
      emergencyLevel: map['emergency_level'] as String?,
    );
  }

  AICase copyWith({
    String? caseId,
    String? cpr,
    String? age,
    String? gender,
    String? chronicDisease,
    String? possibleDisease,
    String? emergencyLevel,
  }) {
    return AICase(
      caseId: caseId ?? this.caseId,
      cpr: cpr ?? this.cpr,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      chronicDisease: chronicDisease ?? this.chronicDisease,
      possibleDisease: possibleDisease ?? this.possibleDisease,
      emergencyLevel: emergencyLevel ?? this.emergencyLevel,
    );
  }
}
