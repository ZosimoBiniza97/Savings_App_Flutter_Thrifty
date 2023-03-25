import 'package:moor_flutter/moor_flutter.dart';
import 'package:thrifty/database.dart';

part 'database.g.dart';

class Users extends Table {
  TextColumn get firstname => text()();
  TextColumn get lastname => text()();
  TextColumn get username => text()();
  TextColumn get email => text()();
  TextColumn get password => text()();
}

@UseMoor(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
    FlutterQueryExecutor.inDatabaseFolder(
      path: 'db.sqlite',
      logStatements: true,
    ),
  );

  @override
  int get schemaVersion => 1;
}

// Add a sample user to the database
