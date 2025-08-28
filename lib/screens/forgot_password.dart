import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5), // lavender
      body: SafeArea(
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't worry! Enter your email and we'll send you a reset link.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Reset Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF39C50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _resetPassword,
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  ),
                ),
              ),
              ),

              const SizedBox(height: 24),

              // Feedback message
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('sent') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              const SizedBox(height: 32),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),)
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Forgot Password')),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: _emailController,
  //             decoration: const InputDecoration(labelText: 'Enter your email'),
  //             keyboardType: TextInputType.emailAddress,
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: _resetPassword,
  //             child: const Text('Reset Password'),
  //           ),
  //           const SizedBox(height: 16),
  //           Text(_message, style: const TextStyle(color: Colors.red)),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => const LoginScreen()),
  //               );
  //             },
  //             child: const Text('Back to Login'),
  //           ),

  //         ],
  //       ),
  //     ),
  //   );
  // }

  
}
