import 'mandatory.dart';
import 'user.dart';
import 'borrow_request.dart';
import 'return_detail.dart';

class ReturnRequest extends Mandatory {
  final int borrowRequestId;
  final int? userId;
  final int? handleBy;
  final String status;
  final String? notes;
  final String? rejectionReason;
  final User? user;
  final User? handler;
  final BorrowRequest? borrowRequest;
  final List<ReturnDetail>? returnDetails;

  ReturnRequest({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.borrowRequestId,
    this.userId,
    this.handleBy,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.user,
    this.handler,
    this.borrowRequest,
    this.returnDetails,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      borrowRequestId: json['borrow_request_id'] as int,
      userId: json['user_id'] as int?,
      handleBy: json['handle_by'] as int?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      handler: json['handler'] != null ? User.fromJson(json['handler'] as Map<String, dynamic>) : null,
      borrowRequest: json['borrow_request'] != null
          ? BorrowRequest.fromJson(json['borrow_request'] as Map<String, dynamic>)
          : null,
      returnDetails: json['return_details'] != null
          ? (json['return_details'] as List<dynamic>)
              .map((e) => ReturnDetail.fromJson(e as Map<String, dynamic>))
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
      'borrow_request_id': borrowRequestId,
      'user_id': userId,
      'handle_by': handleBy,
      'status': status,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'user': user?.toJson(),
      'handler': handler?.toJson(),
      'borrow_request': borrowRequest?.toJson(),
      'return_details': returnDetails?.map((e) => e.toJson()).toList(),
    };
  }
}