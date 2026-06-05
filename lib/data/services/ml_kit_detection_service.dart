import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:ecoscan_rewards/data/services/material_mapping_service.dart';

class MlKitDetectionService {
  MlKitDetectionService._();
  static final MlKitDetectionService instance = MlKitDetectionService._();

  ImageLabeler? _imageLabeler;
  ObjectDetector? _objectDetector;

  void _initLabeler() {
    _imageLabeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  void _initObjectDetector() {
    _objectDetector ??= ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
  }

  /// Procesa una imagen y retorna el resultado de detección de material.
  Future<DetectionResult> detectFromFile(File imageFile) async {
    _initLabeler();
    _initObjectDetector();

    final inputImage = InputImage.fromFile(imageFile);

    final labels = <String>[];
    final confidences = <double>[];
    final objects = <String>[];

    try {
      // Image labeling
      final imageLabels = await _imageLabeler!.processImage(inputImage);
      for (final label in imageLabels) {
        labels.add(label.label.toLowerCase());
        confidences.add(label.confidence);
      }
    } catch (_) {}

    try {
      // Object detection
      final detectedObjects = await _objectDetector!.processImage(inputImage);
      for (final obj in detectedObjects) {
        for (final label in obj.labels) {
          objects.add(label.text.toLowerCase());
          if (!labels.contains(label.text.toLowerCase())) {
            labels.add(label.text.toLowerCase());
            confidences.add(label.confidence);
          }
        }
      }
    } catch (_) {}

    // Combinar y mapear
    final allLabels = [...labels, ...objects];
    final allConfidences = [...confidences, ...objects.map((_) => 0.6)];

    return MaterialMappingService.instance.mapLabels(
      allLabels,
      allConfidences,
    );
  }

  Future<void> close() async {
    await _imageLabeler?.close();
    await _objectDetector?.close();
    _imageLabeler = null;
    _objectDetector = null;
  }
}
