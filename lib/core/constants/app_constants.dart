
class AppConstants {
  AppConstants._();

  static const String appName = "EcoScan Rewards";
  static const String appVersion = "1.0.0";

  // Roles
  static const String rolAdmin = "admin";
  static const String rolRecycler = "recycler";

  // Materiales reciclables
  static const String materialPlastic = "plástico";
  static const String materialGlass = "vidrio";
  static const String materialMetal = "metal";
  static const String materialCardboard = "cartón";
  static const String materialPaper = "papel";
  static const String materialUnknown = "desconocido";

  static const List<String> materials = [
    materialPlastic,
    materialGlass,
    materialMetal,
    materialCardboard,
    materialPaper,
    materialUnknown
  ];

  // Puntos por material
  static const Map<String, int> pointsPerMaterial = {
    materialPlastic: 10,
    materialGlass: 15,
    materialMetal: 20,
    materialCardboard: 8,
    materialPaper: 5,
    materialUnknown: 2,
  };

  // Umbrales ML Kit
  static const double minConfidenceThreshold = 0.55;
  static const double highConfidenceThreshold = 0.75;

  // DB
  static const String dbName = 'econscan_rewards.db';
  static const int dbVersion = 1;

  // SharedPreferences keys
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefUserName = 'user_name';
}