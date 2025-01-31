import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/const/colors/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Screens/main/main_screen.dart';
import '../Forgot _Password/forgot_password.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Lockout variables
  int _attemptCounter = 0;
  final int _maxAttempts = 3;
  DateTime? _lockoutEndTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLockoutData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load lockout data from SharedPreferences
  Future<void> _loadLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lockoutEndTimeStr = prefs.getString('lockoutEndTime');
    int? attemptCounter = prefs.getInt('attemptCounter');

    if (lockoutEndTimeStr != null) {
      DateTime lockoutEndTime = DateTime.parse(lockoutEndTimeStr);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        setState(() {
          _lockoutEndTime = lockoutEndTime;
          _attemptCounter = attemptCounter ?? 0;
        });
        _startLockoutTimer();
        _showLockoutDialog();
      } else {
        _clearLockoutData();
      }
    }
  }

  // Save lockout data to SharedPreferences
  Future<void> _saveLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_lockoutEndTime != null) {
      await prefs.setString(
          'lockoutEndTime', _lockoutEndTime!.toIso8601String());
    }
    await prefs.setInt('attemptCounter', _attemptCounter);
  }

  // Clear lockout data from SharedPreferences
  Future<void> _clearLockoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('lockoutEndTime');
    await prefs.remove('attemptCounter');
    setState(() {
      _lockoutEndTime = null;
      _attemptCounter = 0;
    });
  }

  // Start the lockout timer
  void _startLockoutTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        if (_lockoutEndTime == null ||
            DateTime.now().isAfter(_lockoutEndTime!)) {
          timer.cancel();
          _clearLockoutData();
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close the dialog when lockout ends
          }
        }
      }
    });
  }

  // Show the lockout dialog with warning.gif
  void _showLockoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/warning.gif',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Too Many Attempts",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: bgColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Please wait for the timer to expire before retrying.",
                textAlign: TextAlign.center,
                style: TextStyle(color: bgColor),
              ),
              const SizedBox(height: 20),
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (_) {
                  return _lockoutEndTime != null
                      ? _lockoutEndTime!.difference(DateTime.now()).inSeconds
                      : 0;
                }),
                builder: (context, snapshot) {
                  int secondsRemaining = snapshot.data ?? 0;
                  if (secondsRemaining <= 0) {
                    secondsRemaining = 0;
                  }
                  return Text(
                    "$secondsRemaining seconds remaining",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: bgColor),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to check if user is admin
  Future<bool> isAdmin(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'Admin')
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Function to handle login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (_lockoutEndTime != null &&
          DateTime.now().isBefore(_lockoutEndTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait until the lockout period ends.'),
            backgroundColor: red,
            duration: Duration(milliseconds: 700),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // ignore: unused_local_variable
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text);

        bool admin = await isAdmin(_emailController.text.trim());
        Navigator.of(context).pop();

        if (admin) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          _clearLockoutData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not an admin'),
              backgroundColor: red,
            ),
          );
        }
        // ignore: unused_catch_clause
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop();

        _attemptCounter++;
        int attemptsLeft = _maxAttempts - _attemptCounter;

        if (_attemptCounter >= _maxAttempts) {
          _lockoutEndTime = DateTime.now().add(const Duration(minutes: 1));
          _attemptCounter = 0;
          await _saveLockoutData();
          _startLockoutTimer();
          _showLockoutDialog();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many attempts. Please wait for 1 minute.'),
              backgroundColor: red,
              duration: Duration(milliseconds: 700),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login failed. You have $attemptsLeft attempt(s) left.',
              ),
              backgroundColor: red,
              duration: const Duration(milliseconds: 700),
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLockedOut =
        _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AbsorbPointer(
        absorbing: isLockedOut,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLockedOut ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLockedOut ? Colors.grey : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordForm()),
                  );
                },
                child: const Text(
                  'Forgot your password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
