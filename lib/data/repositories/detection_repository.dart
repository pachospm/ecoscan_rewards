import 'package:ecoscan_rewards/data/datasource/local/database_helper.dart';
import 'package:ecoscan_rewards/data/models/detection_log_model.dart';

class DetectionRepository {
  final DatabaseHelper _db;

  DetectionRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<int> insertLog(DetectionLogModel log) async {
    return await _db.insert('detection_logs', log.toMap());
  }

  Future<List<DetectionLogModel>> getLogsByUser(int userId) async {
    final results = await _db.query(
      'detection_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => DetectionLogModel.fromMap(m)).toList();
  }

  Future<List<DetectionLogModel>> getAllLogs() async {
    final results = await _db.query(
      'detection_logs',
      orderBy: 'created_at DESC',
    );
    return results.map((m) => DetectionLogModel.fromMap(m)).toList();
  }

  Future<List<DetectionLogModel>> getLowConfidenceLogs(
      double threshold) async {
    final results = await _db.query(
      'detection_logs',
      where: 'confidence < ?',
      whereArgs: [threshold],
      orderBy: 'confidence ASC',
    );
    return results.map((m) => DetectionLogModel.fromMap(m)).toList();
  }
}
