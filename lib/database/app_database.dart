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
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('Scan')
class Scans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get result => text()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get confidence => real()();
}

@DriftDatabase(tables: [Users, Scans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // --- FIX 1: Increment the schema version ---
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    // --- FIX 2: Add the migration logic for the 'scans' table ---
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // This migration adds the 'email' column to the 'users' table.
        await m.addColumn(users, users.email);
      }
      if (from < 3) {
        // This migration adds the 'confidence' column to the 'scans' table.
        await m.addColumn(scans, scans.confidence);
      }
    },
  );

  // --- User Methods ---
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<User?> getLatestUser() async {
    return (select(users)
      ..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)])
      ..limit(1))
        .getSingleOrNull();
  }

  Future<User?> getUserById(int id) async {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updateUser(UsersCompanion userCompanion) async {
    return await update(users).replace(userCompanion);
  }

  // --- Scan Methods ---
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