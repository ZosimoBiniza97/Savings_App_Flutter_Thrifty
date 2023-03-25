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
Future<void> insertSampleUser() async {
  final db = AppDatabase();

  await db.into(db.users).insert(
    UsersCompanion(
      firstname: Value('John'),
      lastname: Value('Doe'),
      username: Value('johndoe'),
      email: Value('johndoe@example.com'),
      password: Value('password123'),
    ),
  );
}