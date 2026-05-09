
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String role;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convertir el model a Map para insetar/actualizar en SQLite
  Map<String, dynamic> toMap(){
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Crear una copia del modelo con algunos campos modificados
    UserModel copyWith({
      int? id,
      String? name,
      String? email,
      String? passwordHash,
      String? role,
      DateTime? createdAt,
    }){
      return UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt
      );
    }

    @override
    String toString() =>
          'UserModel(id $id, name $name, email $email, role $role)';
}