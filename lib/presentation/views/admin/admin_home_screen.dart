import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/core/animations/scale_tap_animation.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/stat_card.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AdminDashboardViewModel>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final dashVM = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AdminDashboardViewModel>().loadDashboard(),
          color: AppTheme.primaryGreenLight,
          backgroundColor: AppTheme.cardDark,
          child: CustomScrollView(
            slivers: [
              // Header Admin
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
                                'Panel Admin',
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authVM.currentUser?.name ?? '',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        // Badge admin
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentAmber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppTheme.accentAmber.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.admin_panel_settings,
                                  size: 14, color: AppTheme.accentAmber),
                              const SizedBox(width: 6),
                              const Text(
                                'Admin',
                                style: TextStyle(
                                  color: AppTheme.accentAmber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: AppTheme.textSecondary),
                          onPressed: () async {
                            await authVM.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Stats grid
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        StatCard(
                          label: 'Usuarios totales',
                          value: '${dashVM.totalUsers}',
                          icon: Icons.people_outline,
                          iconColor: AppTheme.accentTeal,
                        ),
                        StatCard(
                          label: 'Recicladores',
                          value: '${dashVM.totalRecyclers}',
                          icon: Icons.person_outline,
                          iconColor: AppTheme.primaryGreenLight,
                        ),
                        StatCard(
                          label: 'Reciclajes',
                          value: '${dashVM.totalRecords}',
                          icon: Icons.recycling,
                          iconColor: AppTheme.successGreen,
                        ),
                        StatCard(
                          label: 'Puntos dados',
                          value: '${dashVM.totalPointsGiven}',
                          icon: Icons.stars_rounded,
                          iconColor: AppTheme.accentAmber,
                          valueColor: AppTheme.accentAmber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Menú de módulos
              SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('Módulos', style: theme.textTheme.titleMedium),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _AdminModule(
                        icon: Icons.people_outline,
                        title: 'Usuarios',
                        subtitle: '${dashVM.totalUsers} registrados',
                        color: AppTheme.accentTeal,
                        delay: const Duration(milliseconds: 220),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.users),
                      ),
                      _AdminModule(
                        icon: Icons.recycling,
                        title: 'Registros de reciclaje',
                        subtitle: '${dashVM.totalRecords} en total',
                        color: AppTheme.primaryGreenLight,
                        delay: const Duration(milliseconds: 260),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.recyclingRecords),
                      ),
                      _AdminModule(
                        icon: Icons.find_in_page_outlined,
                        title: 'Revisión de detecciones',
                        subtitle:
                            '${dashVM.lowConfidenceRecords.length} con baja confianza',
                        color: AppTheme.warningAmber,
                        delay: const Duration(milliseconds: 300),
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.detectionReview),
                      ),
                      _AdminModule(
                        icon: Icons.bar_chart_outlined,
                        title: 'Estadísticas',
                        subtitle: 'Por material y usuario',
                        color: AppTheme.accentAmber,
                        delay: const Duration(milliseconds: 340),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.stats),
                      ),
                    ],
                  ),
                ),
              ),
              // Tabla de materiales rápida
              if (dashVM.materialStats.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    delay: const Duration(milliseconds: 380),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text('Materiales reciclados',
                          style: theme.textTheme.titleMedium),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _MaterialsQuickView(
                          stats: dashVM.materialStats),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminModule extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Duration delay;
  final VoidCallback onTap;

  const _AdminModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      delay: delay,
      child: ScaleTapAnimation(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialsQuickView extends StatelessWidget {
  final Map<String, int> stats;
  const _MaterialsQuickView({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: stats.entries.map((entry) {
          final color = AppTheme.materialColors[entry.key] ?? AppTheme.textSecondary;
          final pct = total > 0 ? entry.value / total : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
