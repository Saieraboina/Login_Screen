import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:login_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      // Replace the URL with your API endpoint
      const String apiUrl = 'https://your-api-endpoint.com/login';

      // Create a Dio instance with cache and interceptor
      final Dio dio = Dio();
      dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Add headers to the request
            options.headers['Authorization'] = 'Bearer your_token_here';
            return handler.next(options);
          },
        ),
      );

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      // Make a POST request
      final response = await dio.post(
        apiUrl,
        data: requestData,
        options: buildCacheOptions(const Duration(minutes: 1)),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Redirect to the home screen or do other necessary actions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'An error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
            ),
            if (_isError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
