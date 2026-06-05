import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';

class EcoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? borderRadius;

  const EcoCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppTheme.cardDark,
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        splashColor: AppTheme.primaryGreenLight.withOpacity(0.08),
        highlightColor: AppTheme.primaryGreenLight.withOpacity(0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
