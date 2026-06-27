import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/auth_controller.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';
import 'package:flutter_app/screens/registration_screen.dart';
import 'package:flutter_app/validators/app_validator.dart';
import 'package:flutter_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _credentialError;

  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoginFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_validateLoginForm);
    _passwordController.addListener(_validateLoginForm);
  }

  void _validateLoginForm() {
    final emailError = AppValidator.validateEmail(_emailController.text);
    final passwordError = AppValidator.validateEmpty(
      _passwordController.text,
      'Password',
    );

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _credentialError = null;

      _isLoginFormValid = emailError == null && passwordError == null;
    });
  }

  Future<void> _login() async {
    if (!_isLoginFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _credentialError = null;
    });

    final UserModel? user = await _authController.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user == null) {
      setState(() {
        _credentialError =
            'Invalid email or password. Please register first or check credentials.';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(user: user),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 45),
              const Icon(
                Icons.lock_person,
                size: 90,
                color: Colors.indigo,
              ),
              const SizedBox(height: 14),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue to your dashboard',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock,
                obscureText: !_isPasswordVisible,
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),

              if (_credentialError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _credentialError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Remember Me'),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: _isLoginFormValid && !_isLoading ? _login : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrationScreen(),
                    ),
                  );
                },
                child: const Text('Create New Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}