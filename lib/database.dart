import 'package:moor_flutter/moor_flutter.dart';
// import 'package:thrifty/signup.dart';
part 'database.g.dart';

final db = AppDatabase();

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstname => text()();
  TextColumn get lastname => text()();
  TextColumn get username => text()();
  TextColumn get email => text()();
  TextColumn get password => text()();

  @override
  List<String> get customConstraints => [
    'UNIQUE (username, email)'
  ];
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userid => integer()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get note => text()();
  DateTimeColumn get date => dateTime().nullable()();
}

class Goals extends Table {
  IntColumn get userid => integer()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
}

class Savings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userid => integer()();
  IntColumn get active => integer()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().nullable()();
}


@UseMoor(tables: [Users, Expenses, Goals, Savings])
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

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}