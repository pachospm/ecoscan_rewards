import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminDashboardViewModel>();
      if (!vm.isLoading && vm.materialStats.isEmpty) vm.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreenLight))
          : CustomScrollView(
              slivers: [
                // Resumen global
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text('Resumen global',
                          style: theme.textTheme.titleMedium),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    delay: const Duration(milliseconds: 80),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: 'Reciclajes',
                              value: '${vm.totalRecords}',
                              icon: Icons.recycling,
                              color: AppTheme.primaryGreenLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Puntos dados',
                              value: '${vm.totalPointsGiven}',
                              icon: Icons.stars_rounded,
                              color: AppTheme.accentAmber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Recicladores',
                              value: '${vm.totalRecyclers}',
                              icon: Icons.people_outline,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Distribución por material
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    delay: const Duration(milliseconds: 160),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                      child: Text('Distribución por material',
                          style: theme.textTheme.titleMedium),
                    ),
                  ),
                ),
                if (vm.materialStats.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.bar_chart_outlined,
                      title: 'Sin datos',
                      subtitle: 'No hay reciclajes registrados aún',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = vm.materialStats.entries.toList()[index];
                        final total = vm.materialStats.values
                            .fold(0, (a, b) => a + b);
                        final pct =
                            total > 0 ? entry.value / total : 0.0;
                        final color =
                            AppTheme.materialColors[entry.key] ??
                                AppTheme.textSecondary;

                        return FadeSlideAnimation(
                          delay: Duration(milliseconds: 60 * index),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20, 0, 20, 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.06)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} · ${(pct * 100).round()}%',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(100),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: pct),
                                      duration: const Duration(
                                          milliseconds: 800),
                                      curve: Curves.easeOutCubic,
                                      builder: (_, val, __) =>
                                          LinearProgressIndicator(
                                        value: val,
                                        backgroundColor:
                                            color.withOpacity(0.12),
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(color),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: vm.materialStats.length,
                    ),
                  ),
                // Ranking
                SliverToBoxAdapter(
                  child: FadeSlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text('Top recicladores',
                          style: theme.textTheme.titleMedium),
                    ),
                  ),
                ),
                if (vm.leaderboard.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: 'Sin datos de ranking',
                      subtitle: '',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = vm.leaderboard[index];
                        final name = entry['name'] as String;
                        final pts = entry['total_points'] as int;
                        final medalEmoji = index == 0
                            ? '🥇'
                            : index == 1
                                ? '🥈'
                                : index == 2
                                    ? '🥉'
                                    : '${index + 1}.';

                        return FadeSlideAnimation(
                          delay: Duration(milliseconds: 60 * index),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(
                                20, 0, 20, 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: index < 3
                                  ? AppTheme.accentAmber
                                      .withOpacity(0.06)
                                  : AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: index < 3
                                    ? AppTheme.accentAmber
                                        .withOpacity(0.2)
                                    : Colors.white.withOpacity(0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(medalEmoji,
                                      style:
                                          const TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(name,
                                        style: theme.textTheme.titleMedium)),
                                Text(
                                  '$pts pts',
                                  style: TextStyle(
                                    color: index < 3
                                        ? AppTheme.accentAmber
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: vm.leaderboard.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
