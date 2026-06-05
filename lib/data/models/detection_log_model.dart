class DetectionLogModel {
  final int? id;
  final int userId;
  final String rawLabels;       // Etiquetas de image labeling, separadas por coma
  final String rawObjects;      // Etiquetas de object detection, separadas por coma
  final String mappedMaterial;  // Material que se determinó tras el mapeo
  final double confidence;
  final DateTime createdAt;

  const DetectionLogModel({
    this.id,
    required this.userId,
    required this.rawLabels,
    required this.rawObjects,
    required this.mappedMaterial,
    required this.confidence,
    required this.createdAt,
  });

  factory DetectionLogModel.fromMap(Map<String, dynamic> map) {
    return DetectionLogModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      rawLabels: map['raw_labels'] as String,
      rawObjects: map['raw_objects'] as String,
      mappedMaterial: map['mapped_material'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'raw_labels': rawLabels,
      'raw_objects': rawObjects,
      'mapped_material': mappedMaterial,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DetectionLogModel copyWith({
    int? id,
    int? userId,
    String? rawLabels,
    String? rawObjects,
    String? mappedMaterial,
    double? confidence,
    DateTime? createdAt,
  }) {
    return DetectionLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawLabels: rawLabels ?? this.rawLabels,
      rawObjects: rawObjects ?? this.rawObjects,
      mappedMaterial: mappedMaterial ?? this.mappedMaterial,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}