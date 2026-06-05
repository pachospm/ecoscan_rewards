import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/data/models/detection_log_model.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/data/models/reward_point_model.dart';
import 'package:ecoscan_rewards/data/repositories/detection_repository.dart';
import 'package:ecoscan_rewards/data/repositories/recycling_repository.dart';
import 'package:ecoscan_rewards/data/repositories/reward_repository.dart';
import 'package:ecoscan_rewards/data/services/material_mapping_service.dart';
import 'package:ecoscan_rewards/data/services/ml_kit_detection_service.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';

enum ScanStatus { idle, capturing, detecting, result, saving, saved, error }

class ScanViewModel extends ChangeNotifier {
  final MlKitDetectionService _mlKitService;
  final RecyclingRepository _recyclingRepo;
  final RewardRepository _rewardRepo;
  final DetectionRepository _detectionRepo;
  final RewardCalculationService _rewardCalc;

  ScanViewModel({
    MlKitDetectionService? mlKitService,
    RecyclingRepository? recyclingRepo,
    RewardRepository? rewardRepo,
    DetectionRepository? detectionRepo,
    RewardCalculationService? rewardCalc,
  })  : _mlKitService = mlKitService ?? MlKitDetectionService.instance,
        _recyclingRepo = recyclingRepo ?? RecyclingRepository(),
        _rewardRepo = rewardRepo ?? RewardRepository(),
        _detectionRepo = detectionRepo ?? DetectionRepository(),
        _rewardCalc = rewardCalc ?? RewardCalculationService.instance;

  ScanStatus _status = ScanStatus.idle;
  DetectionResult? _detectionResult;
  String? _selectedMaterial;
  File? _capturedImage;
  String? _errorMessage;
  int _lastPointsAwarded = 0;

  ScanStatus get status => _status;
  DetectionResult? get detectionResult => _detectionResult;
  String? get selectedMaterial => _selectedMaterial;
  File? get capturedImage => _capturedImage;
  String? get errorMessage => _errorMessage;
  int get lastPointsAwarded => _lastPointsAwarded;
  bool get isLoading =>
      _status == ScanStatus.detecting || _status == ScanStatus.saving;

  Future<void> analyzeImage(File image, int userId) async {
    _status = ScanStatus.detecting;
    _capturedImage = image;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _mlKitService.detectFromFile(image);
      _detectionResult = result;
      _selectedMaterial = result.material;

      // Guardar log
      await _detectionRepo.insertLog(DetectionLogModel(
        userId: userId,
        rawLabels: result.rawLabels.join(', '),
        rawObjects: '',
        mappedMaterial: result.material,
        confidence: result.confidence,
        createdAt: DateTime.now(),
      ));

      _status = ScanStatus.result;
    } catch (e) {
      _errorMessage = 'Error al analizar la imagen. Inténtalo de nuevo.';
      _status = ScanStatus.error;
    }

    notifyListeners();
  }

  void selectMaterial(String material) {
    _selectedMaterial = material;
    notifyListeners();
  }

  Future<void> confirmAndSave(int userId) async {
    if (_detectionResult == null || _selectedMaterial == null) return;

    _status = ScanStatus.saving;
    notifyListeners();

    try {
      final points = _rewardCalc.calculatePoints(
        _selectedMaterial!,
        _detectionResult!.confidence,
      );

      final record = RecyclingRecordModel(
        userId: userId,
        detectedMaterial: _detectionResult!.material,
        correctedMaterial: _selectedMaterial != _detectionResult!.material
            ? _selectedMaterial
            : null,
        confidence: _detectionResult!.confidence,
        imagePath: _capturedImage?.path,
        pointsAwarded: points,
        createdAt: DateTime.now(),
      );

      final recordId = await _recyclingRepo.insertRecord(record);

      if (points > 0) {
        await _rewardRepo.insertPoints(RewardPointModel(
          userId: userId,
          points: points,
          source: 'recycling_record_$recordId',
          createdAt: DateTime.now(),
        ));
      }

      _lastPointsAwarded = points;
      _status = ScanStatus.saved;
    } catch (e) {
      _errorMessage = 'Error al guardar el registro.';
      _status = ScanStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = ScanStatus.idle;
    _detectionResult = null;
    _selectedMaterial = null;
    _capturedImage = null;
    _errorMessage = null;
    _lastPointsAwarded = 0;
    notifyListeners();
  }
}
