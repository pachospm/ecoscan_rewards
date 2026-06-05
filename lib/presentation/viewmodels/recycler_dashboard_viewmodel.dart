import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/data/repositories/recycling_repository.dart';
import 'package:ecoscan_rewards/data/repositories/reward_repository.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';

class RecyclerDashboardViewModel extends ChangeNotifier {
  final RecyclingRepository _recyclingRepo;
  final RewardRepository _rewardRepo;
  final RewardCalculationService _rewardCalc;

  RecyclerDashboardViewModel({
    RecyclingRepository? recyclingRepo,
    RewardRepository? rewardRepo,
    RewardCalculationService? rewardCalc,
  })  : _recyclingRepo = recyclingRepo ?? RecyclingRepository(),
        _rewardRepo = rewardRepo ?? RewardRepository(),
        _rewardCalc = rewardCalc ?? RewardCalculationService.instance;

  bool _isLoading = false;
  int _totalPoints = 0;
  int _totalRecycled = 0;
  List<RecyclingRecordModel> _recentRecords = [];
  Map<String, int> _materialStats = {};
  String? _errorMessage;

  bool get isLoading => _isLoading;
  int get totalPoints => _totalPoints;
  int get totalRecycled => _totalRecycled;
  List<RecyclingRecordModel> get recentRecords => _recentRecords;
  Map<String, int> get materialStats => _materialStats;
  String? get errorMessage => _errorMessage;
  UserLevel get userLevel => _rewardCalc.getUserLevel(_totalPoints);
  int get pointsToNextLevel => _rewardCalc.pointsToNextLevel(_totalPoints);
  double get levelProgress => _rewardCalc.levelProgress(_totalPoints);

  Future<void> loadDashboard(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _rewardRepo.getTotalPointsByUser(userId),
        _recyclingRepo.getRecordsByUser(userId),
        _recyclingRepo.getMaterialStatsByUser(userId),
      ]);

      _totalPoints = results[0] as int;
      final records = results[1] as List<RecyclingRecordModel>;
      _totalRecycled = records.length;
      _recentRecords = records.take(5).toList();
      _materialStats = results[2] as Map<String, int>;
    } catch (e) {
      _errorMessage = 'Error al cargar el dashboard.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
