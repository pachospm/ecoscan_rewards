import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ecoscan_rewards/core/routes/app_routes.dart';
import 'package:ecoscan_rewards/core/theme/app_theme.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/viewmodels/scan_viewmodel.dart';
import 'package:ecoscan_rewards/presentation/widgets/loading_overlay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanViewModel>().reset();
    });
  }

  Future<void> _pickFromCamera() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (xfile == null || !mounted) return;
    _analyze(File(xfile.path));
  }

  Future<void> _pickFromGallery() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (xfile == null || !mounted) return;
    _analyze(File(xfile.path));
  }

  void _analyze(File file) {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) return;
    context.read<ScanViewModel>().analyzeImage(file, userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanVM = context.watch<ScanViewModel>();

    if (scanVM.status == ScanStatus.result ||
        scanVM.status == ScanStatus.saving ||
        scanVM.status == ScanStatus.saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.detectionResult);
        }
      });
    }

    return LoadingOverlay(
      isLoading: scanVM.status == ScanStatus.detecting,
      message: 'Analizando residuo con ML Kit...',
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Escanear residuo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // Ilustración central
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreenLight.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.document_scanner_outlined,
                    size: 80,
                    color: AppTheme.primaryGreenLight.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Detecta el material',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Toma una foto del residuo o selecciónala de la galería. ML Kit analizará el material automáticamente.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Botones
                ElevatedButton.icon(
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Abrir cámara'),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Seleccionar de galería'),
                ),
                if (scanVM.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.errorRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.errorRed, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            scanVM.errorMessage!,
                            style: const TextStyle(
                                color: AppTheme.errorRed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
