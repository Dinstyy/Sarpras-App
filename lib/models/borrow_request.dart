import 'mandatory.dart';
import 'user.dart';
import 'borrow_detail.dart';

class BorrowRequest extends Mandatory {
  final DateTime borrowDateExpected;
  final DateTime returnDateExpected;
  final String reason;
  final String? notes;
  final String status;
  final int? userId; // Ubah dari int ke int? untuk mendukung null
  final int? handleBy;
  final String? rejectionReason;
  final User? user;
  final User? handler;
  final List<BorrowDetail>? borrowDetails;

  BorrowRequest({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.borrowDateExpected,
    required this.returnDateExpected,
    required this.reason,
    this.notes,
    required this.status,
    this.userId, // Ubah menjadi nullable
    this.handleBy,
    this.rejectionReason,
    this.user,
    this.handler,
    this.borrowDetails,
  });

factory BorrowRequest.fromJson(Map<String, dynamic> json) {
  return BorrowRequest(
    id: json['id'] as int? ?? 0, // Default ke 0 jika null (meskipun seharusnya ada)
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    borrowDateExpected: DateTime.parse(json['borrow_date_expected'] as String),
    returnDateExpected: DateTime.parse(json['return_date_expected'] as String),
    reason: json['reason'] as String? ?? '',
    notes: json['notes'] as String?,
    status: json['status'] as String? ?? 'unknown',
    userId: json['user_id'] as int?,
    handleBy: json['handle_by'] as int?,
    rejectionReason: json['rejection_reason'] as String?,
    user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    handler: json['handler'] != null ? User.fromJson(json['handler'] as Map<String, dynamic>) : null,
    borrowDetails: json['borrow_details'] != null
        ? (json['borrow_details'] as List<dynamic>)
            .map((e) => BorrowDetail.fromJson(e as Map<String, dynamic>))
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
      'borrow_date_expected': borrowDateExpected.toIso8601String(),
      'return_date_expected': returnDateExpected.toIso8601String(),
      'reason': reason,
      'notes': notes,
      'status': status,
      'user_id': userId, // Bisa null
      'handle_by': handleBy,
      'rejection_reason': rejectionReason,
      'user': user?.toJson(),
      'handler': handler?.toJson(),
      'borrow_details': borrowDetails?.map((e) => e.toJson()).toList(),
    };
  }
}