import 'package:flutter/material.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final bool showLabel;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  Color _colorForConfidence() {
    if (confidence >= AppConstants.highConfidenceThreshold) {
      return AppTheme.successGreen;
    } else if (confidence >= AppConstants.minConfidenceThreshold) {
      return AppTheme.warningAmber;
    }
    return AppTheme.errorRed;
  }

  String _labelForConfidence() {
    if (confidence >= AppConstants.highConfidenceThreshold) return 'Alta';
    if (confidence >= AppConstants.minConfidenceThreshold) return 'Media';
    return 'Baja';
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForConfidence();
    final percent = (confidence * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confianza · ${_labelForConfidence()}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: confidence.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
