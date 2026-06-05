import 'package:ecoscan_rewards/data/datasource/local/database_helper.dart';
import 'package:ecoscan_rewards/data/models/user_model.dart';

class UserRepository {
  final DatabaseHelper _db;

  UserRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<List<UserModel>> getAllUsers() async {
    final results = await _db.query('users', orderBy: 'created_at DESC');
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final results = await _db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'name ASC',
    );
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<int> getTotalUsers() async {
    final results = await _db.rawQuery('SELECT COUNT(*) as count FROM users');
    return results.first['count'] as int;
  }

  Future<int> getTotalRecyclers() async {
    final results = await _db.rawQuery(
      "SELECT COUNT(*) as count FROM users WHERE role = 'recycler'",
    );
    return results.first['count'] as int;
  }
}
