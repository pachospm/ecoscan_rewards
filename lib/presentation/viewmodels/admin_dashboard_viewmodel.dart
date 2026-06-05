import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/data/repositories/recycling_repository.dart';
import 'package:ecoscan_rewards/data/repositories/reward_repository.dart';
import 'package:ecoscan_rewards/data/repositories/user_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final RecyclingRepository _recyclingRepo;
  final RewardRepository _rewardRepo;

  AdminDashboardViewModel({
    UserRepository? userRepo,
    RecyclingRepository? recyclingRepo,
    RewardRepository? rewardRepo,
  })  : _userRepo = userRepo ?? UserRepository(),
        _recyclingRepo = recyclingRepo ?? RecyclingRepository(),
        _rewardRepo = rewardRepo ?? RewardRepository();

  bool _isLoading = false;
  int _totalUsers = 0;
  int _totalRecyclers = 0;
  int _totalRecords = 0;
  int _totalPointsGiven = 0;
  Map<String, int> _materialStats = {};
  List<RecyclingRecordModel> _lowConfidenceRecords = [];
  List<Map<String, dynamic>> _leaderboard = [];

  bool get isLoading => _isLoading;
  int get totalUsers => _totalUsers;
  int get totalRecyclers => _totalRecyclers;
  int get totalRecords => _totalRecords;
  int get totalPointsGiven => _totalPointsGiven;
  Map<String, int> get materialStats => _materialStats;
  List<RecyclingRecordModel> get lowConfidenceRecords => _lowConfidenceRecords;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _userRepo.getTotalUsers(),
        _userRepo.getTotalRecyclers(),
        _recyclingRepo.getTotalRecords(),
        _rewardRepo.getTotalPointsAllUsers(),
        _recyclingRepo.getMaterialStats(),
        _recyclingRepo.getLowConfidenceRecords(
            AppConstants.minConfidenceThreshold),
        _rewardRepo.getLeaderboard(),
      ]);

      _totalUsers = results[0] as int;
      _totalRecyclers = results[1] as int;
      _totalRecords = results[2] as int;
      _totalPointsGiven = results[3] as int;
      _materialStats = results[4] as Map<String, int>;
      _lowConfidenceRecords = results[5] as List<RecyclingRecordModel>;
      _leaderboard = results[6] as List<Map<String, dynamic>>;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
