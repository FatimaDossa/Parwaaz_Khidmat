import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import '../dashboard/butterfly_dashboard.dart';
import '../dashboard/sunshine_dashboard.dart';
import 'forgot_password.dart';


class _PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const _PasswordField({required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: const TextStyle(fontSize: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result.error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error!)),
        );
      } else {
          if (result.user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .get();

          final userType = doc.data()?['userType'];
          if (!mounted) return; 
        
          if (userType == 'SUNSHINE') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SunshineDashboard()),
            );
          } else if (userType == 'BUTTERFLY') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ButterflyDashboard()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown user type.')),
            );
          }
        }
    } }catch (e) {
       if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) {setState(() => _isLoading = false);}
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Title
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: size.width * 0.12, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Form Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          const Text(
                            'EMAIL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: const TextStyle(fontSize: 18),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PasswordField(
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 24),

                          // Login Button
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
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Logging in...',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Links
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                          child: const Text(
                            'Don\'t have an account? Signup Here!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         // Background Image
  //         SizedBox.expand(
  //           child: Image.asset(
  //             'assets/images/login_bg.png', // Replace with your uploaded image
  //             fit: BoxFit.cover,
  //           ),
  //         ),
          
  //         // Main Content
  //         Center(
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const SizedBox(height: 40), // Top spacing
                  
  //                 // Login Title
  //                 const Text(
  //                   'Login',
  //                   style: TextStyle(
  //                     fontSize: 50, // Same font size as Sign Up
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 32),
                  
  //                 // White Container for Form
  //                 Container(
  //                   padding: const EdgeInsets.all(24),
  //                   margin: const EdgeInsets.symmetric(horizontal: 24),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(20),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black12,
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Name Field
  //                       const Text(
  //                         'EMAIL',
  //                         style: TextStyle(
  //                           fontSize: 20, // Same font size as Sign Up
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       TextField(
  //                         controller: _emailController,
  //                         decoration: InputDecoration(
  //                           hintText: 'Enter your email',
  //                           hintStyle: const TextStyle(fontSize: 20),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 16),

  //                       const Text(
  //                         'PASSWORD',
  //                         style: TextStyle(
  //                           fontSize: 20, // Same font size as Sign Up
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       PasswordField(
  //                         controller: _passwordController,
  //                       ),
  //                       // TextField(
  //                       //   controller: _passwordController,
  //                       //   obscureText: true,
  //                       //   decoration: InputDecoration(
  //                       //     hintText: 'Enter your password',
  //                       //     hintStyle: const TextStyle(fontSize: 20),
  //                       //     border: OutlineInputBorder(
  //                       //       borderRadius: BorderRadius.circular(10),
  //                       //     ),
  //                       //   ),
  //                       // ),
  //                       const SizedBox(height: 32),

  //                       // Log In Button
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: const Color(0xFFF39C50), // Orange color
  //                             padding: const EdgeInsets.symmetric(
  //                               vertical: 16,
  //                             ),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                           ),
  //                           onPressed: _handleLogin,
  //                           child: const Text(
  //                             'Log in',
  //                             style: TextStyle(
  //                               fontSize: 25,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // Forgot Password and Signup Links
  //                 Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pushReplacement(
  //                           context,
  //                           MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
  //                         );
  //                       },
  //                       child: const Text(
  //                         'Forgot Password?',
  //                         style: TextStyle(
  //                           fontSize: 25,
  //                           color: Colors.black54,
  //                           decoration: TextDecoration.underline,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pushReplacement(
  //                           context,
  //                           MaterialPageRoute(builder: (_) => const SignupScreen()),
  //                         );
  //                       },
  //                       child: const Text(
  //                         'Don\'t have an account? Signup Here!',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           color: Colors.black54,
  //                           decoration: TextDecoration.underline,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Log In")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: _emailController,
  //             decoration: const InputDecoration(labelText: "Email"),
  //           ),
  //           TextField(
  //             controller: _passwordController,
  //             obscureText: true,
  //             decoration: const InputDecoration(labelText: "Password"),
  //           ),
  //           const SizedBox(height: 20),
  //           _isLoading
  //               ? const CircularProgressIndicator()
  //               : ElevatedButton(
  //                   onPressed: _handleLogin,
  //                   child: const Text("Log In"),
  //                 ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => const SignupScreen()),
  //               );
  //             },
  //             child: const Text("Don't have an account? Sign up"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
