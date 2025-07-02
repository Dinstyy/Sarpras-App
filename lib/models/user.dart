import 'mandatory.dart';

class User extends Mandatory {
  final String name;
  final String? username;
  final String? email;
  final String role;
  final String? kelas;

  User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    this.username,
    this.email,
    required this.role,
    this.kelas,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Validasi field wajib
    final id = json['id'] as int?;
    final createdAtStr = json['created_at'] as String?;
    final updatedAtStr = json['updated_at'] as String?;
    final role = json['role'] as String?;
    final name = json['name'] as String?;

    if (id == null || createdAtStr == null || updatedAtStr == null || role == null || name == null) {
      throw FormatException('Missing required fields in User JSON: $json');
    }

    // Validasi dan parsing tanggal
    final createdAt = DateTime.tryParse(createdAtStr);
    final updatedAt = DateTime.tryParse(updatedAtStr);
    if (createdAt == null || updatedAt == null) {
      throw FormatException('Invalid date format in User JSON: $json');
    }

    return User(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'] as String) : null,
      name: name,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: role,
      kelas: json['kelas'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'kelas': kelas,
    };
  }
}