import '../dio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DioService _dioService;
  static const String _endpoint = '/auth';

  AuthService(this._dioService);

Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    final role = username.length == 10 ? 'siswa' : username.length == 18 ? 'guru' : null;
    if (role == null) {
      print('Invalid username length: $username');
      return {
        'success': false,
        'message': 'Panjang username tidak valid',
        'data': null
      };
    }

    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: '$_endpoint/login',
      data: {
        'username': username,
        'password': password,
        'role': role, // Reintroduce role in the request
      },
    );

    print('AuthService login response: $response');
    if (response['success'] == true && response['content']['token'] != null) {
      _dioService.setToken(response['content']['token']);
      final user = response['content']['user'];
      if (user != null && user['role'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', user['role']);
      }
      return response;
    } else {
      print('AuthService login failed: ${response['message']}');
      return {
        'success': false,
        'message': response['message'] as String? ?? 'Login gagal',
        'data': null
      };
    }
  } catch (e) {
    print('AuthService login error: $e');
    return {
      'success': false,
      'message': e.toString(),
      'data': null
    };
  }
}

  Future<void> logout() async {
    try {
      await _dioService.post<Map<String, dynamic>>(
        endpoint: '$_endpoint/logout',
      );
    } catch (e) {
      print('Logout error: $e'); // Debug
    }
    _dioService.setToken('');
  }
}