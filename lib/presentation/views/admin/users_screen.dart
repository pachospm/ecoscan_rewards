import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/utils/date_util.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/models/user_model.dart';
import 'package:ecoscan_rewards/data/repositories/user_repository.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final repo = UserRepository();
    _users = await repo.getAllUsers();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primaryGreenLight))
          : _users.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline,
                  title: 'Sin usuarios',
                  subtitle: 'No hay usuarios registrados',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primaryGreenLight,
                  backgroundColor: AppTheme.cardDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return FadeSlideAnimation(
                        delay: Duration(milliseconds: 50 * index),
                        child: _UserTile(user: user),
                      );
                    },
                  ),
                ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == AppConstants.rolAdmin;
    final roleColor =
        isAdmin ? AppTheme.accentAmber : AppTheme.primaryGreenLight;
    final initials = user.name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desde ${DateUtil.formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: roleColor.withOpacity(0.3)),
            ),
            child: Text(
              isAdmin ? 'Admin' : 'Reciclador',
              style: TextStyle(
                color: roleColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
