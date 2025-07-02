import 'package:riverpod/riverpod.dart';
import 'package:sarpras_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dio_service.dart';
import '../services/api_services/auth_service.dart';

final dioServiceProvider = Provider<DioService>((ref) {
  return DioService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dioService = ref.watch(dioServiceProvider);
  return AuthService(dioService);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? userData;
  final String? token;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userData,
    this.token,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(isLoading: true);

  const AuthState.authenticated({
    required User userData,
    required String token,
  }) : this(
          isAuthenticated: true,
          userData: userData,
          token: token,
        );

  const AuthState.error(String errorMessage) : this(error: errorMessage);

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? userData,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userData: userData ?? this.userData,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final DioService _dioService;

  AuthNotifier(this._authService, this._dioService)
      : super(const AuthState.initial());

Future<bool> login({required String username, required String password, String? role}) async {
  state = const AuthState.loading();

  try {
    final result = await _authService.login(username, password);

    print('AuthNotifier login result: $result');
    if (result['success'] == true) {
      final token = result['content']['token'] as String?;
      final userJson = result['content']['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        print('Token or user data missing');
        state = AuthState.error('Data login tidak lengkap');
        return false;
      }

      final user = User.fromJson(userJson);
      if (user.id == null) {
        print('User ID is null');
        state = AuthState.error('User ID tidak ditemukan');
        return false;
      }

      _dioService.setToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', user.role ?? role ?? (username.length == 10 ? 'siswa' : 'guru'));

      state = AuthState.authenticated(
        userData: user,
        token: token,
      );

      return true;
    } else {
      print('Login failed: ${result['message']}');
      state = AuthState.error(result['message'] as String? ?? 'Login gagal');
      return false;
    }
  } catch (e) {
    print('Login exception: $e');
    state = AuthState.error(e.toString());
    return false;
  }
}

  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      await _authService.logout();
      _dioService.setToken('');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
    } catch (e) {
      print('Logout error: $e');
    }

    state = const AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final dioService = ref.watch(dioServiceProvider);
  return AuthNotifier(authService, dioService);
});