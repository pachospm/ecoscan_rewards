import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/utils/hash_util.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertSeedData(db);
  }

  Future<void> _createTables(Database db) async {
    // Tabla users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'recycler',
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla recycling_records
    await db.execute('''
      CREATE TABLE recycling_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        detected_material TEXT NOT NULL,
        corrected_material TEXT,
        confidence REAL NOT NULL DEFAULT 0.0,
        image_path TEXT,
        points_awarded INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tabla reward_points
    await db.execute('''
      CREATE TABLE reward_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        points INTEGER NOT NULL,
        source TEXT NOT NULL,
        create_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tabla detection_logs
    await db.execute('''
      CREATE TABLE detection_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        raw_labels TEXT NOT NULL,
        raw_objects TEXT NOT NULL,
        mapped_material TEXT NOT NULL,
        confidence REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now();
    final adminHash = HashUtil.hashPassword('admin123');
    final recyclerHash = HashUtil.hashPassword('recycler123');

    // Usuarios semilla
    await db.insert('users', {
      'name': 'Administrador',
      'email': 'admin@ecoscan.com',
      'password_hash': adminHash,
      'role': AppConstants.rolAdmin,
      'created_at': now.subtract(const Duration(days: 30)).toIso8601String(),
    });

    await db.insert('users', {
      'name': 'María García',
      'email': 'maria@ecoscan.com',
      'password_hash': recyclerHash,
      'role': AppConstants.rolRecycler,
      'created_at': now.subtract(const Duration(days: 15)).toIso8601String(),
    });

    await db.insert('users', {
      'name': 'Carlos López',
      'email': 'carlos@ecoscan.com',
      'password_hash': recyclerHash,
      'role': AppConstants.rolRecycler,
      'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
    });

    // Registros de reciclaje semilla para usuario 2 (María)
    final records = [
      {
        'user_id': 2,
        'detected_material': AppConstants.materialPlastic,
        'corrected_material': null,
        'confidence': 0.88,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialPlastic],
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'user_id': 2,
        'detected_material': AppConstants.materialMetal,
        'corrected_material': null,
        'confidence': 0.92,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialMetal],
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'user_id': 2,
        'detected_material': AppConstants.materialGlass,
        'corrected_material': null,
        'confidence': 0.79,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialGlass],
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'user_id': 2,
        'detected_material': AppConstants.materialUnknown,
        'corrected_material': AppConstants.materialCardboard,
        'confidence': 0.42,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialCardboard],
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      // Registros para Carlos
      {
        'user_id': 3,
        'detected_material': AppConstants.materialPaper,
        'corrected_material': null,
        'confidence': 0.81,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialPaper],
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'user_id': 3,
        'detected_material': AppConstants.materialCardboard,
        'corrected_material': null,
        'confidence': 0.85,
        'image_path': null,
        'points_awarded':
            AppConstants.pointsPerMaterial[AppConstants.materialCardboard],
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];

    for (final record in records) {
      final id = await db.insert('recycling_records', record);
      // Insertar puntos correspondientes
      await db.insert('reward_points', {
        'user_id': record['user_id'],
        'points': record['points_awarded'],
        'source': 'recycling_record_$id',
        'create_at': record['created_at'],
      });
    }

    // Detection logs semilla
    await db.insert('detection_logs', {
      'user_id': 2,
      'raw_labels': 'bottle, container, plastic',
      'raw_objects': 'bottle',
      'mapped_material': AppConstants.materialPlastic,
      'confidence': 0.88,
      'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
    });

    await db.insert('detection_logs', {
      'user_id': 2,
      'raw_labels': 'can, metal, aluminum',
      'raw_objects': 'can',
      'mapped_material': AppConstants.materialMetal,
      'confidence': 0.92,
      'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
    });
  }

  // -----------------------------------------------------------------------
  // Métodos genéricos CRUD
  // -----------------------------------------------------------------------

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }
}
