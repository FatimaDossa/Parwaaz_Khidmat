// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class CoverScreen extends StatelessWidget {
//   const CoverScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFECCFF5), // lavender
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/bird.png',
//                 width: 220,
//                 fit: BoxFit.contain,
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'PARWAAZ',
//                 style: TextStyle(
//                   fontSize: 50,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class CoverScreen extends StatefulWidget {
  const CoverScreen({super.key});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        _progress += 0.01;
      });

      if (_progress >= 1.0) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5), // lavender
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/bird.png',
              width: 220,
              fit: BoxFit.contain,
            ),

            // ✅ Progress bar added ONLY here
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.black87),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'PARWAAZ',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
