import 'package:ecoscan_rewards/core/constants/app_constants.dart';

class DetectionResult {
  final String material;
  final double confidence;
  final List<String> rawLabels;

  const DetectionResult({
    required this.material,
    required this.confidence,
    required this.rawLabels,
  });
}

class MaterialMappingService {
  MaterialMappingService._();
  static final MaterialMappingService instance = MaterialMappingService._();

  // Mapeo de etiquetas ML Kit a materiales reciclables
  static const Map<String, String> _labelToMaterial = {
    // Plástico
    'bottle': AppConstants.materialPlastic,
    'plastic': AppConstants.materialPlastic,
    'plastic bottle': AppConstants.materialPlastic,
    'container': AppConstants.materialPlastic,
    'plastic bag': AppConstants.materialPlastic,
    'packaging': AppConstants.materialPlastic,
    'food packaging': AppConstants.materialPlastic,
    'jug': AppConstants.materialPlastic,
    'cup': AppConstants.materialPlastic,
    'plastic wrap': AppConstants.materialPlastic,
    'straw': AppConstants.materialPlastic,
    'tray': AppConstants.materialPlastic,

    // Vidrio
    'glass': AppConstants.materialGlass,
    'glass bottle': AppConstants.materialGlass,
    'jar': AppConstants.materialGlass,
    'wine bottle': AppConstants.materialGlass,
    'beer bottle': AppConstants.materialGlass,
    'mirror': AppConstants.materialGlass,
    'window': AppConstants.materialGlass,

    // Metal
    'can': AppConstants.materialMetal,
    'metal': AppConstants.materialMetal,
    'aluminum': AppConstants.materialMetal,
    'aluminium': AppConstants.materialMetal,
    'tin': AppConstants.materialMetal,
    'steel': AppConstants.materialMetal,
    'iron': AppConstants.materialMetal,
    'copper': AppConstants.materialMetal,
    'foil': AppConstants.materialMetal,
    'cola': AppConstants.materialMetal,
    'soda can': AppConstants.materialMetal,

    // Cartón
    'cardboard': AppConstants.materialCardboard,
    'box': AppConstants.materialCardboard,
    'carton': AppConstants.materialCardboard,
    'package': AppConstants.materialCardboard,
    'corrugated': AppConstants.materialCardboard,
    'pizza box': AppConstants.materialCardboard,
    'shipping box': AppConstants.materialCardboard,
    'cereal box': AppConstants.materialCardboard,

    // Papel
    'paper': AppConstants.materialPaper,
    'document': AppConstants.materialPaper,
    'newspaper': AppConstants.materialPaper,
    'magazine': AppConstants.materialPaper,
    'book': AppConstants.materialPaper,
    'notebook': AppConstants.materialPaper,
    'envelope': AppConstants.materialPaper,
    'receipt': AppConstants.materialPaper,
    'flyer': AppConstants.materialPaper,
    'brochure': AppConstants.materialPaper,
    'tissue': AppConstants.materialPaper,
  };

  /// Mapea una lista de etiquetas de ML Kit a un material reciclable.
  DetectionResult mapLabels(List<String> labels, List<double> confidences) {
    if (labels.isEmpty) {
      return const DetectionResult(
        material: AppConstants.materialUnknown,
        confidence: 0.0,
        rawLabels: [],
      );
    }

    // Normalizar etiquetas a minúsculas
    final normalizedLabels =
        labels.map((l) => l.toLowerCase().trim()).toList();

    // Verificar reglas de combinación
    final combinationResult = _checkCombinations(normalizedLabels, confidences);
    if (combinationResult != null) return combinationResult;

    // Buscar coincidencia por etiqueta individual (prioridad por confianza)
    String? bestMaterial;
    double bestConfidence = 0.0;

    for (int i = 0; i < normalizedLabels.length; i++) {
      final label = normalizedLabels[i];
      final confidence = i < confidences.length ? confidences[i] : 0.0;

      final material = _labelToMaterial[label];
      if (material != null && confidence > bestConfidence) {
        bestMaterial = material;
        bestConfidence = confidence;
      }
    }

    // Búsqueda parcial si no hubo coincidencia exacta
    if (bestMaterial == null) {
      for (int i = 0; i < normalizedLabels.length; i++) {
        final label = normalizedLabels[i];
        final confidence = i < confidences.length ? confidences[i] : 0.0;

        for (final entry in _labelToMaterial.entries) {
          if (label.contains(entry.key) || entry.key.contains(label)) {
            if (confidence > bestConfidence) {
              bestMaterial = entry.value;
              bestConfidence = confidence;
            }
          }
        }
      }
    }

    if (bestMaterial == null ||
        bestConfidence < AppConstants.minConfidenceThreshold) {
      return DetectionResult(
        material: AppConstants.materialUnknown,
        confidence: bestConfidence,
        rawLabels: labels,
      );
    }

    return DetectionResult(
      material: bestMaterial,
      confidence: bestConfidence,
      rawLabels: labels,
    );
  }

  DetectionResult? _checkCombinations(
    List<String> labels,
    List<double> confidences,
  ) {
    final labelsSet = labels.toSet();

    if (labelsSet.contains('bottle') && labelsSet.contains('glass')) {
      final idx = labels.indexOf('bottle');
      return DetectionResult(
        material: AppConstants.materialGlass,
        confidence: idx < confidences.length ? confidences[idx] : 0.7,
        rawLabels: labels,
      );
    }

    if (labelsSet.contains('bottle') && labelsSet.contains('plastic')) {
      final idx = labels.indexOf('bottle');
      return DetectionResult(
        material: AppConstants.materialPlastic,
        confidence: idx < confidences.length ? confidences[idx] : 0.7,
        rawLabels: labels,
      );
    }

    return null;
  }

  String formatLabels(List<String> labels) => labels.join(', ');
}
