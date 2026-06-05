import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/utils/date_util.dart';
import 'package:ecoscan_rewards/data/models/recycling_record_model.dart';
import 'package:ecoscan_rewards/presentation/widgets/material_badge.dart';

class RecyclingRecordTile extends StatelessWidget {
  final RecyclingRecordModel record;
  final String? userName;

  const RecyclingRecordTile({
    super.key,
    required this.record,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // Icono de material
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.recycling,
              color: AppTheme.primaryGreenLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MaterialBadge(material: record.finalMaterial),
                    if (record.wasCorrected) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Corregido',
                          style: TextStyle(
                            color: AppTheme.warningAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                if (userName != null)
                  Text(
                    userName!,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                Text(
                  DateUtil.formatRelative(record.createdAt),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          // Puntos
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${record.pointsAwarded}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: record.pointsAwarded > 0
                      ? AppTheme.successGreen
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'pts',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
