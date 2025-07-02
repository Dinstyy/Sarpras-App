import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sarpras_app/services/dio_service.dart';
import 'package:sarpras_app/models/paginate_response.dart';
import 'package:sarpras_app/models/return_request.dart';

class ReturnRequestService {
  final DioService _dioService;

  ReturnRequestService(this._dioService);

  Future<PaginateResponse<ReturnRequest>> getAll({
    String? status,
    int? userId,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/return-requests',
        queryParameters: {
          'status': status,
          'user_id': userId,
          'page': page,
          'size': size,
        },
      );
      return PaginateResponse.fromJson(
        response,
        (json) => ReturnRequest.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ReturnRequest> getById(int id) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/return-requests/$id',
      );
      return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReturnRequest> create({
    required int borrowRequestId,
    String? notes,
    List<Map<String, dynamic>>? items,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'borrow_request_id': borrowRequestId,
        'notes': notes,
        'items': items ?? [],
      });
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path, filename: 'return_proof.jpg'),
          ),
        );
      }
      final response = await _dioService.post(
        endpoint: '/user/return-requests',
        data: formData,
      );
      return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReturnRequest>> getUserReturnHistory(int userId, {String? status}) async {
    try {
      final response = await _dioService.get(
        endpoint: '/user/return-history',
        queryParameters: {'status': status},
      );
      return (response['data'] as List<dynamic>)
          .map((e) => ReturnRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}