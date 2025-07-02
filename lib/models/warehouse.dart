import 'mandatory.dart';
import 'item_unit.dart';

class Warehouse extends Mandatory {
  final String name;
  final String location;
  final int capacity;
  final List<ItemUnit>? itemUnits;

  Warehouse({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.location,
    required this.capacity,
    this.itemUnits,
  });

factory Warehouse.fromJson(Map<String, dynamic> json) {
  return Warehouse(
    id: json['id'] ?? 0, // fallback aman
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    name: json['name'] ?? 'Tidak ada nama',
    location: json['location'] ?? '',
    capacity: json['capacity'] ?? 0,
    itemUnits: (json['item_units'] as List?)?.map((e) => ItemUnit.fromJson(e)).toList(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'name': name,
      'location': location,
      'capacity': capacity,
      'item_units': itemUnits?.map((e) => e.toJson()).toList(),
    };
  }
}