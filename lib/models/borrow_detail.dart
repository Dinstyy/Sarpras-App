import 'mandatory.dart';
import 'item_unit.dart';

class BorrowDetail extends Mandatory {
  final int quantity;
  final int borrowRequestId;
  final int itemUnitId;
  final ItemUnit? itemUnit;

  BorrowDetail({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.quantity,
    required this.borrowRequestId,
    required this.itemUnitId,
    this.itemUnit,
  });

  factory BorrowDetail.fromJson(Map<String, dynamic> json) {
    return BorrowDetail(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      quantity: json['quantity'] as int,
      borrowRequestId: json['borrow_request_id'] as int,
      itemUnitId: json['item_unit_id'] as int,
      itemUnit: json['item_unit'] != null ? ItemUnit.fromJson(json['item_unit'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'quantity': quantity,
      'borrow_request_id': borrowRequestId,
      'item_unit_id': itemUnitId,
      'item_unit': itemUnit?.toJson(),
    };
  }
}