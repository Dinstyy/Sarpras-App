import '../../models/user.dart';
import '../../models/paginate_response.dart';
import '../dio_service.dart';

class UserService {
  final DioService _dioService;
  static const String _endpoint = '/users';

  UserService(this._dioService);

  Future<List<User>> getAll({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: _endpoint,
        queryParameters: queryParameters,
      );

      if (response == null) {
        return [];
      }

      final paginatedResponse = PaginateResponse.fromJson(
        response["content"],
        (json) => User.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.data;
    } catch (e) {
      // Error in UserService.getAll
      return [];
    }
  }

  Future<User> getById(int id) async {
    final response = await _dioService.get<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<User> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: _endpoint,
      data: data,
    );
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<User> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
      data: data,
    );
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
  }
} 