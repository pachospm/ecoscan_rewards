import 'package:ecoscan_rewards/core/utils/hash_util.dart';
import 'package:ecoscan_rewards/data/datasource/local/database_helper.dart';
import 'package:ecoscan_rewards/data/models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _db;

  AuthRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<UserModel?> login(String email, String password) async {
    final results = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );

    if (results.isEmpty) return null;

    final user = UserModel.fromMap(results.first);
    if (!HashUtil.verifyPassword(password, user.passwordHash)) return null;

    return user;
  }

  Future<UserModel?> getUserById(int id) async {
    final results = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }
}
