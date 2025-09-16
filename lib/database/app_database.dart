import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get gender => text()();
  TextColumn get ageGroup => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('Scan')
class Scans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get result => text()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [Users, Scans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- User Methods ---
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<User?> getLatestUser() {
    return (select(users)
      ..orderBy(
          [(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)]))
        .getSingleOrNull();
  }

  Future<bool> updateUser(UsersCompanion user) => update(users).replace(user);

  // --- Scan Methods (Moved inside the class) ---
  Future<int> insertScan(ScansCompanion scan) => into(scans).insert(scan);

  Future<List<Scan>> getScansForUser(int userId) {
    return (select(scans)
      ..where((s) => s.userId.equals(userId))
      ..orderBy(
          [(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.desc)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aeye.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}