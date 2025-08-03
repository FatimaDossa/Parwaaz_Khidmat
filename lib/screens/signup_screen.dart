import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../dashboard/butterfly_dashboard.dart';
import '../dashboard/sunshine_dashboard.dart';

const TextStyle _labelStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle _dropdownItemStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 18),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);



class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
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


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedUserType = 'SUNSHINE';
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);

    try {
      // final user = await _authService.signUp(
      //   _emailController.text.trim(),
      //   _passwordController.text.trim(),
      //   _selectedUserType,
      //   _usernameController.text.trim(),
      // );

      final result = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedUserType,
        _usernameController.text.trim(),
      );

      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error!)),
        );
      } else {
        if (result.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful!')),
          );
          // final userType = doc.data()?['userType'];

          if (_selectedUserType == 'SUNSHINE') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SunshineDashboard()),
            );
          } else if (_selectedUserType == 'BUTTERFLY') {
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
    } } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         // Background Image
  //         SizedBox.expand(
  //           child: Image.asset(
  //             'assets/images/signup_bg.png', // Replace with your uploaded image
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
  //                 // Sign Up Title
  //                 const Text(
  //                   'Sign Up',
  //                   style: TextStyle(
  //                     fontSize: 50, // Larger font size for emphasis
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Log In Link
  //                 GestureDetector(
  //                   onTap: () {
  //                     // Navigate explicitly to the LoginScreen
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(builder: (context) => const LoginScreen()),
  //                     );
  //                   },
  //                   child: const Text(
  //                     'Already Registered? Log in here.',
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       color: Colors.black54,
  //                       decoration: TextDecoration.underline,
  //                     ),
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
  //                         color: Colors.black,
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Username Field
  //                       const Text(
  //                         'USERNAME',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       TextField(
  //                         controller: _usernameController,
  //                         decoration: InputDecoration(
  //                           hintText: 'Enter your username',
  //                           hintStyle: const TextStyle(fontSize: 20),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 16),

  //                       // Email Field
  //                       const Text(
  //                         'EMAIL',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       TextField(
  //                         controller: _emailController,
  //                         decoration: InputDecoration(
  //                           hintText: 'Enter Email',
  //                           hintStyle: const TextStyle(fontSize: 20),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 16),

  //                       // Password Field
  //                       const Text(
  //                         'PASSWORD',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       PasswordField(controller: _passwordController),
  //                       // TextField(
  //                       //   obscureText: true,
  //                       //   controller: _passwordController,
  //                       //   decoration: InputDecoration(
  //                       //     hintText: 'Enter your password',
  //                       //     hintStyle: const TextStyle(fontSize: 20),
  //                       //     border: OutlineInputBorder(
  //                       //       borderRadius: BorderRadius.circular(10),
  //                       //     ),
  //                       //   ),
  //                       // ),
  //                       const SizedBox(height: 16),

  //                       // Group Dropdown
  //                       const Text(
  //                         'GROUP',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       DropdownButtonFormField<String>(
  //                         decoration: InputDecoration(
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                         ),
  //                         items: const [
  //                           DropdownMenuItem(
  //                             value: 'SUNSHINE',
  //                             child: Text(
  //                               'Sunshine ☀️',
  //                               style: TextStyle(
  //                                 fontSize:
  //                                     20, // Increased font size for dropdown values
  //                                 fontWeight: FontWeight
  //                                     .bold, // Optional: Make text bold
  //                                 color:
  //                                     Colors.black, // Optional: Set text color
  //                               ),
  //                             ),
  //                           ),
  //                           DropdownMenuItem(
  //                             value: 'BUTTERFLY',
  //                             child: Text(
  //                               'Butterfly 🦋',
  //                               style: TextStyle(
  //                                 fontSize:
  //                                     20, // Increased font size for dropdown values
  //                                 fontWeight: FontWeight
  //                                     .bold, // Optional: Make text bold
  //                                 color:
  //                                     Colors.black, // Optional: Set text color
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                         onChanged: (value) {
  //                           setState(() {
  //                             _selectedUserType = value!;
  //                           });
  //                         },
  //                       ),
  //                       const SizedBox(height: 32),

  //                       // Sign Up Button
  //                       SizedBox(
  //                         width: double.infinity,
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: const Color.fromARGB(
  //                               255,
  //                               235,
  //                               120,
  //                               20,
  //                             ), // Orange color
  //                             padding: const EdgeInsets.symmetric(vertical: 16),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                           ),
  //                           onPressed: _handleSignup,
  //                           child: const Text(
  //                             'Sign up',
  //                             style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  
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
              'assets/images/signup_bg.png',
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
                    // Title
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: size.width * 0.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Already Registered
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Already Registered? Log in here.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          const Text('USERNAME', style: _labelStyle),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            decoration: _inputDecoration('Enter your username'),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          const Text('EMAIL', style: _labelStyle),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: _inputDecoration('Enter Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text('PASSWORD', style: _labelStyle),
                          const SizedBox(height: 8),
                          PasswordField(controller: _passwordController),
                          const SizedBox(height: 16),

                          // Dropdown
                          const Text('GROUP', style: _labelStyle),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'SUNSHINE',
                                child: Text('Sunshine ☀️', style: _dropdownItemStyle),
                              ),
                              DropdownMenuItem(
                                value: 'BUTTERFLY',
                                child: Text('Butterfly 🦋', style: _dropdownItemStyle),
                              ),
                            ],
                            value: _selectedUserType,
                            onChanged: (value) {
                              setState(() {
                                _selectedUserType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Signup Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEB7814),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                                          'Signing in...',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                'Sign up',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
