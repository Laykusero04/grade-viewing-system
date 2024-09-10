import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../components/custom_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        final userCredential = await authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
        if (userCredential != null) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          throw Exception('Login failed');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 34, 32, 31),
              Color.fromARGB(255, 46, 18, 0)
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school,
                          size: 80, color: AppTheme.darkOrange),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Grade Viewer',
                      style:
                          AppTheme.headlineStyle.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your email'
                                : null,
                          ),
                          SizedBox(height: 20),
                          _buildInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            obscureText: true,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your password'
                                : null,
                          ),
                          SizedBox(height: 40),
                          CustomButton(
                            text: 'Login',
                            onPressed: _login,
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[100]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
      ),
      validator: validator,
    );
  }
}
