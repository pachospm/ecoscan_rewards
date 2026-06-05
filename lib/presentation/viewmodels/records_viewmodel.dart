import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/data/models/user_model.dart';
import 'package:ecoscan_rewards/data/repositories/recycling_repository.dart';
import 'package:ecoscan_rewards/data/repositories/user_repository.dart';

class RecordsViewModel extends ChangeNotifier {
  final RecyclingRepository _recyclingRepo;
  final UserRepository _userRepo;

  RecordsViewModel({
    RecyclingRepository? recyclingRepo,
    UserRepository? userRepo,
  })  : _recyclingRepo = recyclingRepo ?? RecyclingRepository(),
        _userRepo = userRepo ?? UserRepository();

  bool _isLoading = false;
  List<RecyclingRecordModel> _records = [];
  List<UserModel> _users = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<RecyclingRecordModel> get records => _records;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;

  String getUserName(int userId) {
    final user = _users.where((u) => u.id == userId).firstOrNull;
    return user?.name ?? 'Usuario #$userId';
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _recyclingRepo.getAllRecords(),
        _userRepo.getAllUsers(),
      ]);
      _records = results[0] as List<RecyclingRecordModel>;
      _users = results[1] as List<UserModel>;
    } catch (e) {
      _errorMessage = 'Error al cargar registros.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadByUser(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _recyclingRepo.getRecordsByUser(userId);
    } catch (e) {
      _errorMessage = 'Error al cargar registros.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
