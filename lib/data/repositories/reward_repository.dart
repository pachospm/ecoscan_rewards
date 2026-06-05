import 'package:ecoscan_rewards/data/datasource/local/database_helper.dart';
import 'package:ecoscan_rewards/data/models/reward_point_model.dart';

class RewardRepository {
  final DatabaseHelper _db;

  RewardRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<int> insertPoints(RewardPointModel model) async {
    return await _db.insert('reward_points', model.toMap());
  }

  Future<List<RewardPointModel>> getPointsByUser(int userId) async {
    final results = await _db.query(
      'reward_points',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'create_at DESC',
    );
    return results.map((m) => RewardPointModel.fromMap(m)).toList();
  }

  Future<int> getTotalPointsByUser(int userId) async {
    final results = await _db.rawQuery(
      'SELECT COALESCE(SUM(points), 0) as total FROM reward_points WHERE user_id = ?',
      [userId],
    );
    return results.first['total'] as int;
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return await _db.rawQuery('''
      SELECT u.name, u.email, COALESCE(SUM(rp.points), 0) as total_points
      FROM users u
      LEFT JOIN reward_points rp ON u.id = rp.user_id
      WHERE u.role = 'recycler'
      GROUP BY u.id
      ORDER BY total_points DESC
      LIMIT 10
    ''');
  }

  Future<int> getTotalPointsAllUsers() async {
    final results = await _db.rawQuery(
      'SELECT COALESCE(SUM(points), 0) as total FROM reward_points',
    );
    return results.first['total'] as int;
  }
}
