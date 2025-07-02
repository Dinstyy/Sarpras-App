import 'package:dio/dio.dart';
import '../../models/item.dart';
import '../dio_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

/// Service for handling Item API requests
class ItemService {
  final DioService _dioService;
  static const String endpoint = '/user/items'; // Sesuai dengan endpoint Laravel kamu

  ItemService(this._dioService);

  /// Get all items with optional filtering and sorting
  Future<List<Item>> getAll({
    String? search,
    String? type,
    String? sortBy,
    String? sortDir,
    bool withCategory = true,
    bool withItemUnits = false, // Tambahan untuk relasi itemUnits
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortDir != null && sortDir.isNotEmpty) {
        queryParams['sortDir'] = sortDir;
      }

      if (withCategory || withItemUnits) {
        List<String> relations = [];
        if (withCategory) relations.add('category');
        if (withItemUnits) relations.add('itemUnits');
        queryParams['with'] = relations.join(',');
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final itemsData = content['data'] as List<dynamic>;

        return itemsData
            .map((json) => Item.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch items');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Get a specific item by ID
  Future<Item> getById(int id, {bool withCategory = true, bool withItemUnits = false}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (withCategory || withItemUnits) {
        List<String> relations = [];
        if (withCategory) relations.add('category');
        if (withItemUnits) relations.add('itemUnits');
        queryParams['with'] = relations.join(',');
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        return Item.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Get items by category ID
  Future<List<Item>> getByCategoryId(int categoryId, {bool withCategory = true, bool withItemUnits = false}) async {
    try {
      Map<String, dynamic> queryParams = {'category_id': categoryId};

      if (withCategory || withItemUnits) {
        List<String> relations = [];
        if (withCategory) relations.add('category');
        if (withItemUnits) relations.add('itemUnits');
        queryParams['with'] = relations.join(',');
      }

      queryParams['sortBy'] = 'name';
      queryParams['sortDir'] = 'asc';

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final itemsData = content['data'] as List<dynamic>;

        return itemsData
            .map((json) => Item.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch items by category');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Create a new item
  Future<Item> create(Map<String, dynamic> data) async {
    try {
      final response = await _dioService.post<Map<String, dynamic>>(
        endpoint: endpoint,
        data: data,
      );

      if (response['success'] == true && response['content'] != null) {
        return Item.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to create item');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Update an existing item
  Future<Item> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.put<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
        data: data,
      );

      if (response['success'] == true && response['content'] != null) {
        return Item.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to update item');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Delete an item
  Future<void> delete(int id) async {
    try {
      final response = await _dioService.delete<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
      );

      if (response['success'] != true) {
        throw ApiException(response['message'] ?? 'Failed to delete item');
      }
    } catch (e) {
      if (e is DioException) {
        throw ApiException('Network error: ${e.message}');
      }
      throw ApiException('An error occurred: $e');
    }
  }

  /// Search items by name
  Future<List<Item>> searchByName(String name) async {
    return getAll(search: name, withCategory: true);
  }

  /// Filter items by category
  Future<List<Item>> filterByCategory(int categoryId) async {
    return getByCategoryId(categoryId, withCategory: true);
  }
}