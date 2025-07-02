import 'package:sarpras_app/models/borrow_request.dart';
import 'package:sarpras_app/models/paginate_response.dart';
import 'package:sarpras_app/services/dio_service.dart';

class BorrowRequestService {
  final DioService _dioService;

  BorrowRequestService(this._dioService);

  Future<PaginateResponse<BorrowRequest>> getAll({
    String? status,
    int? userId,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/borrow-requests',
        queryParameters: {
          'status': status,
          'user_id': userId,
          'page': page,
          'size': size,
        },
      );
      return PaginateResponse.fromJson(
        response,
        (json) => BorrowRequest.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BorrowRequest> getById(int id) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/borrow-requests/$id',
      );
      return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BorrowRequest> create({
    required DateTime borrowDateExpected,
    required DateTime returnDateExpected,
    required String reason,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dioService.post(
        endpoint: '/user/borrow-requests',
        data: {
          'borrow_date_expected': borrowDateExpected.toIso8601String(),
          'return_date_expected': returnDateExpected.toIso8601String(),
          'reason': reason,
          'notes': notes,
          'items': items,
        },
      );
      return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> returnItem(int id) async {
    try {
      await _dioService.post(
        endpoint: '/user/borrow-requests/$id/return',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginateResponse<BorrowRequest>> getActiveBorrows(int userId) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/active-borrows',
        queryParameters: {'user_id': userId},
      );
      return PaginateResponse.fromJson(
        response,
        (json) => BorrowRequest.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BorrowRequest>> getUserBorrowHistory(int userId, {String? status}) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/borrow-history',
        queryParameters: {'status': status},
      );
      return (response['data'] as List<dynamic>)
          .map((e) => BorrowRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}