import 'package:ecoscan_rewards/data/datasource/local/database_helper.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';

class RecyclingRepository {
  final DatabaseHelper _db;

  RecyclingRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<int> insertRecord(RecyclingRecordModel record) async {
    return await _db.insert('recycling_records', record.toMap());
  }

  Future<List<RecyclingRecordModel>> getRecordsByUser(int userId) async {
    final results = await _db.query(
      'recycling_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => RecyclingRecordModel.fromMap(m)).toList();
  }

  Future<List<RecyclingRecordModel>> getAllRecords() async {
    final results = await _db.query(
      'recycling_records',
      orderBy: 'created_at DESC',
    );
    return results.map((m) => RecyclingRecordModel.fromMap(m)).toList();
  }

  Future<List<RecyclingRecordModel>> getLowConfidenceRecords(
      double threshold) async {
    final results = await _db.query(
      'recycling_records',
      where: 'confidence < ?',
      whereArgs: [threshold],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => RecyclingRecordModel.fromMap(m)).toList();
  }

  Future<Map<String, int>> getMaterialStats() async {
    final results = await _db.rawQuery('''
      SELECT detected_material, COUNT(*) as count
      FROM recycling_records
      GROUP BY detected_material
      ORDER BY count DESC
    ''');

    return {
      for (final row in results)
        row['detected_material'] as String: row['count'] as int
    };
  }

  Future<Map<String, int>> getMaterialStatsByUser(int userId) async {
    final results = await _db.rawQuery('''
      SELECT detected_material, COUNT(*) as count
      FROM recycling_records
      WHERE user_id = ?
      GROUP BY detected_material
      ORDER BY count DESC
    ''', [userId]);

    return {
      for (final row in results)
        row['detected_material'] as String: row['count'] as int
    };
  }

  Future<int> getTotalRecords() async {
    final results = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM recycling_records',
    );
    return results.first['count'] as int;
  }
}
