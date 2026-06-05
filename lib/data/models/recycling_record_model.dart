
class RecyclingRecordModel {
  final int? id;
  final int userId;
  final String detectedMaterial;
  final String? correctedMaterial;
  final double confidence;
  final String? imagePath;
  final int pointsAwarded;
  final DateTime createdAt;

  const RecyclingRecordModel({
    this.id,
    required this.userId,
    required this.detectedMaterial,
    this.correctedMaterial,
    required this.confidence,
    this.imagePath,
    required this.pointsAwarded,
    required this.createdAt
  });

  String get finalMaterial => correctedMaterial ?? detectedMaterial;
  bool get wasCorrected => correctedMaterial != null && correctedMaterial != detectedMaterial;

  factory RecyclingRecordModel.fromMap(Map<String, dynamic> map){
    return RecyclingRecordModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      detectedMaterial: map['detected_material'] as String,
      correctedMaterial: map['corrected_material'] as String?,
      confidence: (map['confidence'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      pointsAwarded: map['points_awarded'] as int,
      createdAt: DateTime.parse(map['created_at'] as String)
    );
  }

  Map<String, dynamic> toMap(){
    return {
      if (id != null) 'id' : id,
      'user_id': userId,
      'detected_material': detectedMaterial,
      'corrected_material': correctedMaterial,
      'confidence': confidence,
      'image_path': imagePath,
      'points_awarded': pointsAwarded,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RecyclingRecordModel copyWith({
    int? id,
    int? userId,
    String? detectedMaterial,
    String? correctedMaterial,
    double? confidence,
    String? imagePath,
    int? pointsAwarded,
    DateTime? createdAt,
  }) {
    return RecyclingRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      detectedMaterial: detectedMaterial ?? this.detectedMaterial,
      correctedMaterial: correctedMaterial ?? this.correctedMaterial,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      createdAt: createdAt ?? this.createdAt
    );
  }


}