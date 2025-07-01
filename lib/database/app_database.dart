import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart'; // This will be generated using build_runner

// User table
@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get gender => text()();
  TextColumn get ageGroup => text()();
}

// Scan result table
@DataClassName('ScanResult')
class ScanResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().customConstraint('REFERENCES users(id)')();
  TextColumn get imagePath => text()();
  TextColumn get result => text()();
  DateTimeColumn get timestamp => dateTime()();
}

// Drift database class
@DriftDatabase(tables: [Users, ScanResults])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // User operations
  Future<int> insertUser(UsersCompanion user) =>
      into(users).insert(user, mode: InsertMode.insertOrReplace);

  Future<User?> getUserById(int id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<List<User>> getAllUsers() => select(users).get();

  // ADD THIS METHOD - updateUser
  Future<bool> updateUser(User user) async {
    return await (update(users)..where((u) => u.id.equals(user.id)))
        .write(UsersCompanion(
      name: Value(user.name),
      gender: Value(user.gender),
      ageGroup: Value(user.ageGroup),
    )) > 0;
  }

  // Alternative updateUser method using UsersCompanion
  Future<bool> updateUserWithCompanion(int userId, UsersCompanion companion) async {
    return await (update(users)..where((u) => u.id.equals(userId)))
        .write(companion) > 0;
  }

  // Method to update specific fields
  Future<bool> updateUserFields(int userId, {
    String? name,
    String? gender,
    String? ageGroup,
  }) async {
    return await (update(users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(
      name: name != null ? Value(name) : Value.absent(),
      gender: gender != null ? Value(gender) : Value.absent(),
      ageGroup: ageGroup != null ? Value(ageGroup) : Value.absent(),
    )) > 0;
  }

  // Scan result operations
  Future<int> insertScan(ScanResultsCompanion scan) =>
      into(scanResults).insert(scan);

  Future<List<ScanResult>> getScansForUser(int userId) =>
      (select(scanResults)..where((s) => s.userId.equals(userId))).get();
}

// Lazy database init
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'aeye.sqlite'));
    return NativeDatabase(file);
  });
}