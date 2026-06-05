import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';

class MaterialBadge extends StatelessWidget {
  final String material;
  final bool large;

  const MaterialBadge({
    super.key,
    required this.material,
    this.large = false,
  });

  static IconData _iconForMaterial(String material) {
    switch (material) {
      case AppConstants.materialPlastic:
        return Icons.water_drop_outlined;
      case AppConstants.materialGlass:
        return Icons.wine_bar_outlined;
      case AppConstants.materialMetal:
        return Icons.hardware_outlined;
      case AppConstants.materialCardboard:
        return Icons.inventory_2_outlined;
      case AppConstants.materialPaper:
        return Icons.article_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
        AppTheme.materialColors[material] ?? AppTheme.textSecondary;
    final iconSize = large ? 20.0 : 14.0;
    final fontSize = large ? 14.0 : 11.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForMaterial(material), color: color, size: iconSize),
          const SizedBox(width: 6),
          Text(
            material,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
