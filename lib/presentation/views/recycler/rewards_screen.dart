import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/utils/date_util.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/reward_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) context.read<RewardViewModel>().load(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RewardViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Recompensas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreenLight,
          labelColor: AppTheme.primaryGreenLight,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Mis puntos'),
            Tab(text: 'Ranking'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreenLight))
          : TabBarView(
              controller: _tabController,
              children: [
                _MyPointsTab(vm: vm),
                _LeaderboardTab(vm: vm),
              ],
            ),
    );
  }
}

class _MyPointsTab extends StatelessWidget {
  final RewardViewModel vm;
  const _MyPointsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeSlideAnimation(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreenDark, AppTheme.accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    vm.userLevel.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vm.totalPoints}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'puntos totales',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nivel ${vm.userLevel.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (vm.userLevel != UserLevel.platinum) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: vm.levelProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${vm.pointsToNextLevel} pts para el siguiente nivel',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text('Historial de puntos', style: theme.textTheme.titleMedium),
          ),
        ),
        if (vm.pointHistory.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.stars_rounded,
              title: 'Sin puntos aún',
              subtitle: 'Comienza a reciclar para acumular puntos',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final point = vm.pointHistory[index];
                return FadeSlideAnimation(
                  delay: Duration(milliseconds: 40 * index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentAmber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: AppTheme.accentAmber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reciclaje registrado',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontSize: 14),
                              ),
                              Text(
                                DateUtil.formatRelative(point.createdAt),
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${point.points}',
                          style: const TextStyle(
                            color: AppTheme.accentAmber,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: vm.pointHistory.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final RewardViewModel vm;
  const _LeaderboardTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.leaderboard.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'Sin datos de ranking',
        subtitle: 'Los recicladores aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      itemCount: vm.leaderboard.length,
      itemBuilder: (context, index) {
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
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: index < 3
                  ? AppTheme.accentAmber.withOpacity(0.06)
                  : AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: index < 3
                    ? AppTheme.accentAmber.withOpacity(0.2)
                    : Colors.white.withOpacity(0.06),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    medalEmoji,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$pts pts',
                  style: TextStyle(
                    color: index < 3
                        ? AppTheme.accentAmber
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
