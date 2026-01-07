import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smart_property_inspection/inspectiondata.dart';

class DatabaseHelper {
  static const _databaseName = "propertyinspector.db";
  static const _databaseVersion = 2;
  static const tablename = 'tbl_inspections';

  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tablename (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            property_name TEXT,
            address TEXT,
            description TEXT,
            rating TEXT,
            latitude REAL,
            longitude REAL,
            date_created TEXT,
            photos TEXT
          )
        ''');
      },
    );
  }

  //  INSERT DATA
  Future<int> insertMyList(InspectionData inspection) async {
    final db = await database;
    final data = inspection.toMap();
    data.remove('id');
    return await db.insert(tablename, data);
  }

  // UPDATE DATA
  Future<int> updateMyList(InspectionData inspection) async {
    final db = await database;
    return await db.update(
      tablename,
      inspection.toMap(),
      where: 'id = ?',
      whereArgs: [inspection.id],
    );
  }

  // ================= DELETE =================
  Future<int> deleteMyList(int id) async {
    final db = await database;
    return await db.delete(
      tablename,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= SEARCH =================
  Future<List<InspectionData>> searchMyList(String keyword) async {
    final db = await database;
    final result = await db.query(
      tablename,
      where:
          'property_name LIKE ? OR address LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'date_created DESC',
    );
    return result.map((e) => InspectionData.fromMap(e)).toList();
  }

  // ================= GET LIST =================
  Future<List<InspectionData>> getMyListsPaginated(
      int limit, int offset) async {
    final db = await database;
    final result = await db.query(
      tablename,
      orderBy: 'date_created DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((e) => InspectionData.fromMap(e)).toList();
  }
}
