import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/utils/date_util.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/data/repositories/recycling_repository.dart';
import 'package:ecoscan_rewards/data/repositories/user_repository.dart';
import 'package:ecoscan_rewards/presentation/widgets/confidence_indicator.dart';
import 'package:ecoscan_rewards/presentation/widgets/empty_state.dart';
import 'package:ecoscan_rewards/presentation/widgets/material_badge.dart';

class DetectionReviewScreen extends StatefulWidget {
  const DetectionReviewScreen({super.key});

  @override
  State<DetectionReviewScreen> createState() => _DetectionReviewScreenState();
}

class _DetectionReviewScreenState extends State<DetectionReviewScreen> {
  List<RecyclingRecordModel> _records = [];
  Map<int, String> _userNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final recyclingRepo = RecyclingRepository();
    final userRepo = UserRepository();

    final records = await recyclingRepo
        .getLowConfidenceRecords(AppConstants.minConfidenceThreshold);
    final users = await userRepo.getAllUsers();

    _records = records;
    _userNames = {for (final u in users) u.id!: u.name};

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Revisión de detecciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Banner informativo
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.warningAmber.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: AppTheme.warningAmber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Registros con confianza menor al '
                    '${(AppConstants.minConfidenceThreshold * 100).round()}%',
                    style: const TextStyle(
                      color: AppTheme.warningAmber,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryGreenLight))
                : _records.isEmpty
                    ? const EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'Sin revisiones pendientes',
                        subtitle:
                            'Todas las detecciones tienen alta confianza',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppTheme.primaryGreenLight,
                        backgroundColor: AppTheme.cardDark,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final r = _records[index];
                            return FadeSlideAnimation(
                              delay: Duration(milliseconds: 50 * index),
                              child: _ReviewTile(
                                record: r,
                                userName: _userNames[r.userId] ??
                                    'Usuario #${r.userId}',
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final RecyclingRecordModel record;
  final String userName;

  const _ReviewTile({required this.record, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningAmber.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MaterialBadge(material: record.finalMaterial),
              if (record.wasCorrected) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Corregido: ${record.correctedMaterial}',
                    style: const TextStyle(
                        color: AppTheme.accentTeal, fontSize: 11),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '+${record.pointsAwarded} pts',
                style: const TextStyle(
                  color: AppTheme.accentAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConfidenceIndicator(confidence: record.confidence),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(userName,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              const Spacer(),
              Text(
                DateUtil.formatRelative(record.createdAt),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
