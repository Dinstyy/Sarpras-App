import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _isRememberMe = false;

  @override
  void initState() {
    super.initState();
    // Load credentials after the first frame to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load saved username from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    // final savedPassword = prefs.getString('saved_password'); // Uncomment for password storage

    if (savedUsername != null && mounted) {
      setState(() {
        _usernameController.text = savedUsername;
        _isRememberMe = true; // Check the box if credentials are saved
      });
    }

    // if (savedPassword != null && mounted) {
    //   _passwordController.text = savedPassword; // Uncomment for password storage
    // }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRememberMe) {
      await prefs.setString('saved_username', username);
      // await prefs.setString('saved_password', password); // Uncomment for password storage
    } else {
      await prefs.remove('saved_username');
      // await prefs.remove('saved_password'); // Uncomment for password storage
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Masukkan username dan password', true);
      return;
    }
    if (username.length != 10 && username.length != 18) {
      _showSnackBar('Username harus 10 atau 18 digit', true);
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final authNotifier = ref.read(authProvider.notifier);
    print('Attempting login with username: $username');

    // Determine role based on username length
    final role = username.length == 10 ? 'siswa' : 'guru';

    try {
      final success = await authNotifier.login(
        username: username,
        password: _passwordController.text.trim(),
        role: role,
      );

      print('Login success: $success');
      if (success) {
        // Save credentials if Remember Me is checked
        await _saveCredentials(username, _passwordController.text.trim());

        // Get the token and user data from the auth provider
        final userData = ref.read(authProvider).userData;
        final token = ref.read(authProvider).token;
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('role', userData?.role ?? role);
        } else {
          _showSnackBar('No token received from server', true);
          setState(() {
            _isLoggingIn = false;
          });
          return;
        }

        if (mounted) {
          final role = ref.read(authProvider).userData?.role ?? (username.length == 10 ? 'siswa' : 'guru');
          print('Navigating to home with role: $role');
          try {
            context.goNamed('home', extra: {'role': role});
            print('Navigation to home triggered');
          } catch (e) {
            print('Navigation error: $e');
            _showSnackBar('Gagal navigasi ke home: $e', true);
          }
        } else {
          print('Widget not mounted, skipping navigation');
        }
      } else {
        final error = ref.read(authProvider).error ?? 'Login gagal';
        print('Login error: $error');
        _showSnackBar(error, true);
      }
    } catch (e) {
      print('Login attempt error: $e');
      _showSnackBar('Error login: $e', true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/onboarding');
                },
                child: Image.asset('assets/icon.png', height: 60),
              ),
              const SizedBox(height: 32),
              Text(
                'Masuk ke akun Anda',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan username dan password',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan username',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                  labelText: 'Username',
                  labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
                  labelText: 'Password',
                  labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isRememberMe,
                    onChanged: (value) {
                      setState(() {
                        _isRememberMe = value!;
                      });
                    },
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    'Ingat saya',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9333EA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoggingIn ? null : _login,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoggingIn)
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(right: 12),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Klik disini untuk '),
                    TextSpan(
                      text: 'Caraka',
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showSnackBar('Form login caraka belum tersedia', true);
                        },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}