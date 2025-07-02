import 'mandatory.dart';
import 'item.dart';

class Category extends Mandatory {
  final String slug;
  final String name;
  final String? description;
  final List<Item>? items;

  Category({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.slug,
    required this.name,
    this.description,
    this.items,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
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
      'slug': slug,
      'name': name,
      'description': description,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}