import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/recycler_dashboard_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/stat_card.dart';
import 'package:ecoscan_rewards/presentation/widgets/recycling_record_tile.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';
import 'package:ecoscan_rewards/core/animations/scale_tap_animation.dart';

class RecyclerHomeScreen extends StatefulWidget {
  const RecyclerHomeScreen({super.key});

  @override
  State<RecyclerHomeScreen> createState() => _RecyclerHomeScreenState();
}

class _RecyclerHomeScreenState extends State<RecyclerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) {
      context.read<RecyclerDashboardViewModel>().loadDashboard(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final dashVM = context.watch<RecyclerDashboardViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppTheme.primaryGreenLight,
          backgroundColor: AppTheme.cardDark,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FadeSlideAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, ${user?.name.split(' ').first ?? ''} 👋',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sigue reciclando y ganando puntos',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        _AvatarMenu(
                          name: user?.name ?? '',
                          onLogout: () async {
                            await context.read<AuthViewModel>().logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            }
                          },
                          onProfile: () =>
                              Navigator.pushNamed(context, AppRoutes.profile),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Nivel y progreso
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: _LevelCard(
                    points: dashVM.totalPoints,
                    level: dashVM.userLevel,
                    progress: dashVM.levelProgress,
                    pointsToNext: dashVM.pointsToNextLevel,
                  ),
                ),
              ),
              // Stats
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 160),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Puntos totales',
                            value: '${dashVM.totalPoints}',
                            icon: Icons.stars_rounded,
                            iconColor: AppTheme.accentAmber,
                            valueColor: AppTheme.accentAmber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Reciclajes',
                            value: '${dashVM.totalRecycled}',
                            icon: Icons.recycling,
                            iconColor: AppTheme.primaryGreenLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Botón escanear
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 220),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: ScaleTapAnimation(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.scan)
                              .then((_) => _loadData()),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryGreenLight,
                              AppTheme.accentTeal,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreenLight.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Escanear residuo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Acciones rápidas
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 280),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.history,
                            label: 'Historial',
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.recyclingHistory),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.emoji_events_outlined,
                            label: 'Recompensas',
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.rewards),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_outline,
                            label: 'Perfil',
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.profile),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Actividad reciente
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 340),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Actividad reciente',
                            style: theme.textTheme.titleMedium),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.recyclingHistory),
                          child: const Text('Ver todo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (dashVM.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreenLight,
                      ),
                    ),
                  ),
                )
              else if (dashVM.recentRecords.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.recycling,
                    title: 'Sin actividad aún',
                    subtitle: 'Escanea tu primer residuo para comenzar',
                    action: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.scan),
                      child: const Text('Escanear ahora'),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = dashVM.recentRecords[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 2),
                        child: FadeSlideAnimation(
                          delay: Duration(milliseconds: 60 * index),
                          child: RecyclingRecordTile(record: record),
                        ),
                      );
                    },
                    childCount: dashVM.recentRecords.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int points;
  final UserLevel level;
  final double progress;
  final int pointsToNext;

  const _LevelCard({
    required this.points,
    required this.level,
    required this.progress,
    required this.pointsToNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreenDark,
              AppTheme.accentTeal.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreenLight.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  level.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel ${level.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$points puntos acumulados',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            if (level != UserLevel.platinum) ...[
              const SizedBox(height: 8),
              Text(
                '$pointsToNext pts para el siguiente nivel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreenLight, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  final VoidCallback onProfile;

  const _AvatarMenu({
    required this.name,
    required this.onLogout,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return PopupMenuButton(
      offset: const Offset(0, 50),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          onTap: onProfile,
          child: const Row(
            children: [
              Icon(Icons.person_outline,
                  color: AppTheme.textPrimary, size: 18),
              SizedBox(width: 10),
              Text('Mi perfil',
                  style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onLogout,
          child: const Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorRed, size: 18),
              SizedBox(width: 10),
              Text('Cerrar sesión',
                  style: TextStyle(color: AppTheme.errorRed)),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.primaryGreenLight.withOpacity(0.2),
        child: Text(
          initials,
          style: const TextStyle(
            color: AppTheme.primaryGreenLight,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
