import 'package:ecoscan_rewards/core/constants/app_constants.dart';

class RewardCalculationService {
  RewardCalculationService._();
  static final RewardCalculationService instance =
      RewardCalculationService._();

  /// Calcula los puntos a otorgar según material y confianza.
  int calculatePoints(String material, double confidence) {
    if (material == AppConstants.materialUnknown) return 0;

    final basePoints = AppConstants.pointsPerMaterial[material] ?? 0;

    // Bonus por alta confianza
    if (confidence >= AppConstants.highConfidenceThreshold) {
      return (basePoints * 1.2).round();
    }

    return basePoints;
  }

  /// Calcula el nivel del usuario según puntos totales.
  UserLevel getUserLevel(int totalPoints) {
    if (totalPoints >= 1000) return UserLevel.platinum;
    if (totalPoints >= 500) return UserLevel.gold;
    if (totalPoints >= 200) return UserLevel.silver;
    return UserLevel.bronze;
  }

  /// Puntos necesarios para el siguiente nivel.
  int pointsToNextLevel(int totalPoints) {
    final level = getUserLevel(totalPoints);
    switch (level) {
      case UserLevel.bronze:
        return 200 - totalPoints;
      case UserLevel.silver:
        return 500 - totalPoints;
      case UserLevel.gold:
        return 1000 - totalPoints;
      case UserLevel.platinum:
        return 0;
    }
  }

  double levelProgress(int totalPoints) {
    final level = getUserLevel(totalPoints);
    switch (level) {
      case UserLevel.bronze:
        return totalPoints / 200;
      case UserLevel.silver:
        return (totalPoints - 200) / 300;
      case UserLevel.gold:
        return (totalPoints - 500) / 500;
      case UserLevel.platinum:
        return 1.0;
    }
  }
}

enum UserLevel { bronze, silver, gold, platinum }

extension UserLevelExtension on UserLevel {
  String get label {
    switch (this) {
      case UserLevel.bronze:
        return 'Bronce';
      case UserLevel.silver:
        return 'Plata';
      case UserLevel.gold:
        return 'Oro';
      case UserLevel.platinum:
        return 'Platino';
    }
  }

  String get emoji {
    switch (this) {
      case UserLevel.bronze:
        return '🥉';
      case UserLevel.silver:
        return '🥈';
      case UserLevel.gold:
        return '🥇';
      case UserLevel.platinum:
        return '💎';
    }
  }
}
