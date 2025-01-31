import 'package:flutter/material.dart';
import '../Login_Constants/login_reponsive.dart';
import '../widget/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/bg.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Login Form (Centered)
          const Center(
            child: LoginResponsive(
              child: LoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}
