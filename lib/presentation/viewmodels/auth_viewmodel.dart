import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/data/models/user_model.dart';
import 'package:ecoscan_rewards/data/repositories/auth_repository.dart';
import 'package:ecoscan_rewards/data/services/session_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SessionService _sessionService;

  AuthViewModel({
    AuthRepository? authRepository,
    SessionService? sessionService,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _sessionService = sessionService ?? SessionService.instance;

  AuthStatus _status = AuthStatus.idle;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor completa todos los campos';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(email.trim(), password);
      if (user == null) {
        _errorMessage = 'Credenciales incorrectas';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _sessionService.saveSession(
        userId: user.id!,
        role: user.role,
        name: user.name,
      );

      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión. Inténtalo de nuevo.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
    _currentUser = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<bool> restoreSession() async {
    final userId = await _sessionService.getUserId();
    if (userId == null) return false;

    final user = await _authRepository.getUserById(userId);
    if (user == null) {
      await _sessionService.clearSession();
      return false;
    }

    _currentUser = user;
    _status = AuthStatus.success;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
