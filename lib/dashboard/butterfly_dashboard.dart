// import 'package:flutter/material.dart';

// class SunshineDashboard extends StatelessWidget {
//   const SunshineDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sunshine Dashboard')),
//       body: const Center(child: Text('Welcome, Sunshine! 🎉')),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart'; // adjust path as needed
import '../screens/game_stats_screen.dart'; // adjust path as needed

class ButterflyDashboard extends StatelessWidget {
  final List<Map<String, String>> games = [
    {
      'name': 'Emotion Match',
      'image': 'assets/images/bg4.jpg',
      'id': 'emotion_game',
    },
    {
      'name': 'Classroom Behavior',
      'image': 'assets/images/classroom_bg3.jpg',
      'id': 'classroom_game',
    },
    // Add more games here
  ];

  ButterflyDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5), // lavender
      appBar: AppBar(title: const Text('Butterfly Dashboard'),
      actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          childAspectRatio: 0.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameStatsScreen(gameId: game['id']!),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        game['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      game['name']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

