import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/utils/date_util.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/recycler_dashboard_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().currentUser?.id;
      if (userId != null) {
        context.read<RecyclerDashboardViewModel>().loadDashboard(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final dashVM = context.watch<RecyclerDashboardViewModel>();
    final user = authVM.currentUser;

    final initials = user?.name.isNotEmpty == true
        ? user!.name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              FadeSlideAnimation(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor:
                          AppTheme.primaryGreenLight.withOpacity(0.15),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppTheme.primaryGreenLight,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? '',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.primaryGreenLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color:
                              AppTheme.primaryGreenLight.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Reciclador',
                        style: const TextStyle(
                          color: AppTheme.primaryGreenLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Stats
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Puntos',
                        value: '${dashVM.totalPoints}',
                        icon: Icons.stars_rounded,
                        color: AppTheme.accentAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Reciclajes',
                        value: '${dashVM.totalRecycled}',
                        icon: Icons.recycling,
                        color: AppTheme.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Nivel',
                        value: dashVM.userLevel.label,
                        icon: Icons.military_tech_outlined,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Info
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 180),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Correo electrónico',
                        value: user?.email ?? '',
                        icon: Icons.email_outlined,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Miembro desde',
                        value: user?.createdAt != null
                            ? DateUtil.formatDate(user!.createdAt)
                            : '',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeSlideAnimation(
                delay: const Duration(milliseconds: 260),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authVM.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppTheme.errorRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.errorRed.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
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
              fontSize: 16,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
