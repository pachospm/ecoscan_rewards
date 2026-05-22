import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String recyclerHome = '/recycler/home';
  static const String scan = '/recycler/scan';
  static const String detectionResult = '/recycler/detection-result';
  static const String recyclingHistory = '/recycler/history';
  static const String rewards = '/recycler/rewards';
  static const String profile = '/recycler/profile';
  static const String adminHome = '/admin/home';
  static const String users = '/admin/users';
  static const String recyclingRecords = '/admin/records';
  static const String detectionReview = '/admin/detection-review';
  static const String stats = '/admin/stats';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        recyclerHome: (_) => const RecyclerHomeScreen(),
        scan: (_) => const ScanScreen(),
        detectionResult: (_) => const DetectionResultScreen(),
        recyclingHistory: (_) => const RecyclingHistoryScreen(),
        rewards: (_) => const RewardsScreen(),
        profile: (_) => const ProfileScreen(),
        adminHome: (_) => const AdminHomeScreen(),
        users: (_) => const UsersScreen(),
        recyclingRecords: (_) => const RecyclingRecordsScreen(),
        detectionReview: (_) => const DetectionReviewScreen(),
        stats: (_) => const StatsScreen(),
      };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routes = AppRoutes.routes;
    final builder = routes[settings.name];
    if (builder != null) {
      return _buildRoute(builder, settings);
    }
    return _buildRoute((_) => const SplashScreen(), settings);
  }

  static PageRoute _buildRoute(WidgetBuilder builder, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
