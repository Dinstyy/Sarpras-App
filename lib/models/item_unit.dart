import 'mandatory.dart';
import 'item.dart';
import 'warehouse.dart';

class ItemUnit extends Mandatory {
  final String unitCode;
  final String merk;
  final String condition;
  final String? notes;
  final String diperolehDari;
  final DateTime diperolehTanggal;
  final String status;
  final int quantity;
  final String? qrImage;
  final int itemId;
  final int warehouseId;
  final String? currentLocation;
  final Item? item;
  final Warehouse? warehouse;

  ItemUnit({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.unitCode,
    required this.merk,
    required this.condition,
    this.notes,
    required this.diperolehDari,
    required this.diperolehTanggal,
    required this.status,
    required this.quantity,
    this.qrImage,
    required this.itemId,
    required this.warehouseId,
    this.currentLocation,
    this.item,
    this.warehouse,
  });

  factory ItemUnit.fromJson(Map<String, dynamic> json) {
    return ItemUnit(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      unitCode: json['unit_code'] as String,
      merk: json['merk'] as String,
      condition: json['condition'] as String,
      notes: json['notes'] as String?,
      diperolehDari: json['diperoleh_dari'] as String,
      diperolehTanggal: DateTime.parse(json['diperoleh_tanggal'] as String),
      status: json['status'] as String,
      quantity: json['quantity'] as int,
      qrImage: json['qr_image'] as String?,
      itemId: json['item_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      currentLocation: json['current_location'] as String?,
      item: json['item'] != null
          ? Item.fromJson(json['item'] as Map<String, dynamic>)
          : null,
      warehouse: json['warehouse'] != null
          ? Warehouse.fromJson(json['warehouse'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'unit_code': unitCode,
      'merk': merk,
      'condition': condition,
      'notes': notes,
      'diperoleh_dari': diperolehDari,
      'diperoleh_tanggal': diperolehTanggal.toIso8601String(),
      'status': status,
      'quantity': quantity,
      'qr_image': qrImage,
      'item_id': itemId,
      'warehouse_id': warehouseId,
      'current_location': currentLocation,
      'item': item?.toJson(),
      'warehouse': warehouse?.toJson(),
    };
  }
}
