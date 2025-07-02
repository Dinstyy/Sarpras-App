import 'package:dio/dio.dart';
import '../../models/warehouse.dart';
import '../dio_service.dart';

class WarehouseService {
  final DioService _dioService;
  static const String endpoint = '/user/warehouses';

  WarehouseService(this._dioService);

  Future<List<Warehouse>> getAll({
    String? search,
    String? sortBy,
    String? sortDir,
    bool withItemUnits = false,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      
      if (sortDir != null && sortDir.isNotEmpty) {
        queryParams['sortDir'] = sortDir;
      }
      
      if (withItemUnits) {
        queryParams['with'] = 'itemUnits';
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final warehousesData = content['data'] as List<dynamic>;
        
        return warehousesData
            .map((json) => Warehouse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch warehouses');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<Warehouse> getById(int id) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
      );

      if (response['success'] == true && response['content'] != null) {
        return Warehouse.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch warehouse');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<Warehouse> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: endpoint,
      data: data,
    );
    return Warehouse.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Warehouse> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
      data: data,
    );
    return Warehouse.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
    );
  }
} 