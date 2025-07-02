import 'package:dio/dio.dart';
import '../../models/category.dart';
import '../dio_service.dart';

class CategoryService {
  final DioService _dioService;
  static const String endpoint = '/user/categories';

  CategoryService(this._dioService);

  
  Future<List<Category>> getAll({
    String? sortBy,
    String? sortDir,
    bool withItems = false,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      
      if (sortDir != null && sortDir.isNotEmpty) {
        queryParams['sortDir'] = sortDir;
      }
      
      if (withItems) {
        queryParams['with'] = 'items';
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final categoriesData = content['data'] as List<dynamic>;
        
        return categoriesData
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<Category> getBySlug(String slug) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$slug',
      );

      if (response['success'] == true && response['content'] != null) {
        return Category.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch category');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

Future<Category> getById(int id) async {
  final response = await _dioService.get<Map<String, dynamic>>(
    endpoint: '$endpoint/$id',
  );

  if (response['success'] == true && response['content'] != null) {
    return Category.fromJson(response['content'] as Map<String, dynamic>);
  } else {
    throw ApiException(response['message'] ?? 'Failed to fetch category');
  }
}

  Future<Category> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: endpoint,
      data: data,
    );
    return Category.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Category> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
      data: data,
    );
    return Category.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
    );
  }
} 