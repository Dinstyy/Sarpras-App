import 'package:dio/dio.dart';
import '../../models/item_unit.dart';
import '../dio_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

/// Service for handling ItemUnit API requests
class ItemUnitService {
  final DioService _dioService;
  static const String endpoint = '/user/items-units'; // Sesuai dengan konvensi Laravel kamu

  ItemUnitService(this._dioService);

  /// Get all item units with optional filtering and sorting
  Future<List<ItemUnit>> getAll({
    String? condition,
    String? diperolehDari, // Ganti acquisitionSource
    String? diperolehTanggal, // Ganti acquisitionDate
    String? status,
    int? quantity,
    int? itemId,
    int? warehouseId,
    bool withRelations = true,
    String? sortBy,
    String? sortDir,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (condition != null && condition.isNotEmpty) {
        queryParams['condition'] = condition;
      }

      if (diperolehDari != null && diperolehDari.isNotEmpty) {
        queryParams['diperoleh_dari'] = diperolehDari;
      }

      if (diperolehTanggal != null && diperolehTanggal.isNotEmpty) {
        queryParams['diperoleh_tanggal'] = diperolehTanggal;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (quantity != null) {
        queryParams['quantity'] = quantity.toString();
      }

      if (itemId != null) {
        queryParams['item_id'] = itemId.toString();
      }

      if (warehouseId != null) {
        queryParams['warehouse_id'] = warehouseId.toString();
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortDir != null && sortDir.isNotEmpty) {
        queryParams['sortDir'] = sortDir;
      }

      if (withRelations) {
        queryParams['with'] = 'item,warehouse';
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final itemUnitsData = content['data'] as List<dynamic>;

        return itemUnitsData
            .map((json) => ItemUnit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item units');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Get a specific item unit by unit code
  Future<ItemUnit> getByUnitCode(String unitCode) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/unit-code/$unitCode', // Endpoint disesuaikan
        queryParameters: {'with': 'item,warehouse'},
      );

      if (response['success'] == true && response['content'] != null) {
        return ItemUnit.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item unit');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Get item units by item ID
  Future<List<ItemUnit>> getByItemId(int itemId) async {
    return getAll(
      itemId: itemId,
      withRelations: true,
      sortBy: 'unit_code',
      sortDir: 'asc',
    );
  }

  /// Get item units by warehouse ID
  Future<List<ItemUnit>> getByWarehouseId(int warehouseId) async {
    return getAll(
      warehouseId: warehouseId,
      withRelations: true,
      sortBy: 'unit_code',
      sortDir: 'asc',
    );
  }

  /// Create a new item unit
  Future<ItemUnit> create(Map<String, dynamic> data) async {
    try {
      final response = await _dioService.post<Map<String, dynamic>>(
        endpoint: endpoint,
        data: data,
      );

      if (response['success'] == true && response['content'] != null) {
        return ItemUnit.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to create item unit');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Update an existing item unit
  Future<ItemUnit> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.put<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
        data: data,
      );

      if (response['success'] == true && response['content'] != null) {
        return ItemUnit.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to update item unit');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Delete an item unit
  Future<void> delete(int id) async {
    try {
      final response = await _dioService.delete<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
      );

      if (response['success'] != true) {
        throw ApiException(response['message'] ?? 'Failed to delete item unit');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }
}