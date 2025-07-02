import 'mandatory.dart';
import 'category.dart';
import 'item_unit.dart';

class Item extends Mandatory {
  final String name;
  final String type;
  final String? description;
  final String? image;
  final int categoryId;
  final Category? category;
  final List<ItemUnit>? itemUnits;

  Item({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.type,
    this.description,
    this.image,
    required this.categoryId,
    this.category,
    this.itemUnits,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      categoryId: json['category_id'] as int,
      category: json['category'] != null ? Category.fromJson(json['category'] as Map<String, dynamic>) : null,
      itemUnits: json['item_units'] != null
          ? (json['item_units'] as List<dynamic>)
              .map((e) => ItemUnit.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'name': name,
      'type': type,
      'description': description,
      'image': image,
      'category_id': categoryId,
      'category': category?.toJson(),
      'item_units': itemUnits?.map((e) => e.toJson()).toList(),
    };
  }
}