class Mandatory {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Mandatory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Mandatory.fromJson(Map<String, dynamic> json) {
    // Validasi field wajib
    final id = json['id'] as int?;
    final createdAtStr = json['created_at'] as String?;
    final updatedAtStr = json['updated_at'] as String?;

    if (id == null || createdAtStr == null || updatedAtStr == null) {
      throw FormatException('Missing required fields in Mandatory JSON: $json');
    }

    // Validasi dan parsing tanggal
    final createdAt = DateTime.tryParse(createdAtStr);
    final updatedAt = DateTime.tryParse(updatedAtStr);
    if (createdAt == null || updatedAt == null) {
      throw FormatException('Invalid date format in Mandatory JSON: $json');
    }

    return Mandatory(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'] as String) : null,
    );
  }
}