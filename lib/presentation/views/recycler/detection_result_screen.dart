import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/constants/app_constants.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/core/animations/fade_slide_animation.dart';
import 'package:ecoscan_rewards/data/services/reward_calculation_service.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/scan_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/confidence_indicator.dart';
import 'package:ecoscan_rewards/presentation/widgets/material_badge.dart';
import 'package:ecoscan_rewards/presentation/widgets/loading_overlay.dart';

class DetectionResultScreen extends StatefulWidget {
  const DetectionResultScreen({super.key});

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late Animation<double> _successScale;
  late Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successFade = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _playSuccess() {
    _successController.reset();
    _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final scanVM = context.watch<ScanViewModel>();
    final authVM = context.read<AuthViewModel>();

    if (scanVM.status == ScanStatus.saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playSuccess());
    }

    return LoadingOverlay(
      isLoading: scanVM.status == ScanStatus.saving,
      message: 'Guardando registro...',
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Resultado'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: scanVM.status == ScanStatus.saved
              ? _SavedView(
                  points: scanVM.lastPointsAwarded,
                  scaleAnimation: _successScale,
                  fadeAnimation: _successFade,
                  onDone: () {
                    scanVM.reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.recyclerHome,
                      (r) => false,
                    );
                  },
                )
              : _ResultView(
                  scanVM: scanVM,
                  onConfirm: () =>
                      scanVM.confirmAndSave(authVM.currentUser!.id!),
                  onScanAgain: () {
                    scanVM.reset();
                    Navigator.pop(context);
                  },
                ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ScanViewModel scanVM;
  final VoidCallback onConfirm;
  final VoidCallback onScanAgain;

  const _ResultView({
    required this.scanVM,
    required this.onConfirm,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = scanVM.detectionResult;
    if (result == null) return const SizedBox();

    final rewardCalc = RewardCalculationService.instance;
    final previewPoints = rewardCalc.calculatePoints(
      scanVM.selectedMaterial ?? result.material,
      result.confidence,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview imagen
          if (scanVM.capturedImage != null) ...[
            FadeSlideAnimation(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  scanVM.capturedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Material detectado
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 80),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Material detectado', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  MaterialBadge(material: result.material, large: true),
                  const SizedBox(height: 20),
                  ConfidenceIndicator(confidence: result.confidence),
                  if (result.rawLabels.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Etiquetas ML Kit', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: result.rawLabels
                          .take(6)
                          .map((l) => Chip(label: Text(l)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Corrección manual
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 160),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confirmar o corregir material',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '¿El material es correcto? Si no, selecciona el correcto.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.materials
                        .where((m) => m != AppConstants.materialUnknown)
                        .map((material) {
                      final selected = scanVM.selectedMaterial == material;
                      final color = AppTheme.materialColors[material] ??
                          AppTheme.textSecondary;
                      return GestureDetector(
                        onTap: () => scanVM.selectMaterial(material),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.2)
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? color
                                  : Colors.white.withOpacity(0.1),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            material,
                            style: TextStyle(
                              color: selected ? color : AppTheme.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Puntos preview
          FadeSlideAnimation(
            delay: const Duration(milliseconds: 240),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accentAmber.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      color: AppTheme.accentAmber, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Ganarás $previewPoints puntos',
                    style: const TextStyle(
                      color: AppTheme.accentAmber,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: scanVM.selectedMaterial != null ? onConfirm : null,
            child: const Text('Confirmar y guardar'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onScanAgain,
            child: const Text('Escanear de nuevo'),
          ),
        ],
      ),
    );
  }
}

class _SavedView extends StatelessWidget {
  final int points;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onDone;

  const _SavedView({
    required this.points,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 54,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '¡Reciclaje registrado!',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (points > 0)
                ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: AppTheme.accentAmber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: AppTheme.accentAmber, size: 26),
                        const SizedBox(width: 10),
                        Text(
                          '+$points puntos',
                          style: const TextStyle(
                            color: AppTheme.accentAmber,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (points == 0) ...[
                Text(
                  'Material desconocido. Confirma el tipo para ganar puntos en el próximo escaneo.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onDone,
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
