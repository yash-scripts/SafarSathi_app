import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip_model.dart';

class DatabaseHelper {
  static const _databaseName = 'trips.db';
  static const _databaseVersion = 1;

  static const table = 'trips';

  static const columnId = 'id';
  static const columnStartTime = 'startTime';
  static const columnEndTime = 'endTime';
  static const columnDistance = 'distance';
  static const columnAvgSpeed = 'avgSpeed';
  static const columnIsSynced = 'isSynced';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnStartTime TEXT NOT NULL,
            $columnEndTime TEXT NOT NULL,
            $columnDistance REAL NOT NULL,
            $columnAvgSpeed REAL NOT NULL,
            $columnIsSynced INTEGER NOT NULL
          )
          ''');
  }

  Future<int> insert(Trip trip) async {
    Database db = await instance.database;
    return await db.insert(table, trip.toMap());
  }

  Future<List<Trip>> getUnsyncedTrips() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnIsSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Trip.fromMap(maps[i]);
    });
  }

  Future<int> update(Trip trip) async {
    Database db = await instance.database;
    return await db.update(
      table,
      trip.toMap(),
      where: '$columnId = ?',
      whereArgs: [trip.id],
    );
  }
}
