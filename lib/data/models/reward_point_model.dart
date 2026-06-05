
class RewardPointModel {
  final int? id;
  final int userId;
  final int points;
  final String source;
  final DateTime createdAt;

  const RewardPointModel({
    this.id,
    required this.userId,
    required this.points,
    required this.source,
    required this.createdAt
  });

  factory RewardPointModel.fromMap(Map<String, dynamic>map){
    return RewardPointModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      points: map['points'] as int,
      source: map['source'] as String,
      createdAt: DateTime.parse(map['create_at'] as String),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      if (id != null) 'id' : id,
      'user_id': userId,
      'points': points,
      'source': source,
      'create_at' : createdAt.toIso8601String()
    };
  }

  RewardPointModel copyWith({
    int? id,
    int? userId,
    int? points,
    String? source,
    DateTime? createdAt
  }){
    return RewardPointModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt
    );
  }
}