import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  Future<void> saveSession({
    required int userId,
    required String role,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefUserId, userId);
    await prefs.setString(AppConstants.prefUserRole, role);
    await prefs.setString(AppConstants.prefUserName, name);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserRole);
    await prefs.remove(AppConstants.prefUserName);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefUserId);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserRole);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefUserName);
  }

  Future<bool> isLoggedIn() async {
    final id = await getUserId();
    return id != null;
  }
}
