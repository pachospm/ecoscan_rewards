import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/data/models/reward_point_model.dart';
import 'package:ecoscan_rewards/data/repositories/reward_repository.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';

class RewardViewModel extends ChangeNotifier {
  final RewardRepository _rewardRepo;
  final RewardCalculationService _rewardCalc;

  RewardViewModel({
    RewardRepository? rewardRepo,
    RewardCalculationService? rewardCalc,
  })  : _rewardRepo = rewardRepo ?? RewardRepository(),
        _rewardCalc = rewardCalc ?? RewardCalculationService.instance;

  bool _isLoading = false;
  int _totalPoints = 0;
  List<RewardPointModel> _pointHistory = [];
  List<Map<String, dynamic>> _leaderboard = [];

  bool get isLoading => _isLoading;
  int get totalPoints => _totalPoints;
  List<RewardPointModel> get pointHistory => _pointHistory;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  UserLevel get userLevel => _rewardCalc.getUserLevel(_totalPoints);
  int get pointsToNextLevel => _rewardCalc.pointsToNextLevel(_totalPoints);
  double get levelProgress => _rewardCalc.levelProgress(_totalPoints);

  Future<void> load(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _rewardRepo.getTotalPointsByUser(userId),
        _rewardRepo.getPointsByUser(userId),
        _rewardRepo.getLeaderboard(),
      ]);

      _totalPoints = results[0] as int;
      _pointHistory = results[1] as List<RewardPointModel>;
      _leaderboard = results[2] as List<Map<String, dynamic>>;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
