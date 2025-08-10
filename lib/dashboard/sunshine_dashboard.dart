
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart'; // adjust path as needed
import '../screens/game_stats_screen.dart'; // adjust path as needed

class SunshineDashboard extends StatefulWidget {
  const SunshineDashboard({super.key});

  @override
  State<SunshineDashboard> createState() => _SunshineDashboardState();
}

class _SunshineDashboardState extends State<SunshineDashboard> {
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          username = doc['username'];
        });
      }
    }
  }

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
    // double progress = completedGames / 3.0;
    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5), // lavender
      appBar: AppBar(title: const Text('Sunshine Dashboard'),
      actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hi $username!',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.account_circle, size: 45),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile feature coming soon!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Progress Bar
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     LinearProgressIndicator(
                      //       value: progress,
                      //       color: const Color(0xFFF39C50), // orange
                      //       backgroundColor: Colors.grey[300],
                      //       minHeight: 18,
                      //     ),
                      //     const SizedBox(height: 10),
                      //     Text(
                      //       '$completedGames/3 games',
                      //       style: const TextStyle(fontSize: 18),
                      //     ),
                      //   ],
                      // ),

                      // const SizedBox(height: 30),
                      // Game Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio:
                            0.75, // <--- Adjusted from 0.85 to prevent overflow
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildGameCard(
                            context, 
                            'Learning Ninja',
                            'assets/images/fruit_sunshine.png',
                            const Color(0xFFFFF1C1),
                          ),
                          _buildGameCard(
                            context,
                            'Emotion Explorer',
                            'assets/images/emotion_sunshine.png',
                            const Color(0xFFC1F1FF),
                          ),
                          _buildGameCard(
                            context,
                            'Mannerism Master',
                            'assets/images/mannerism_sunshine.png',
                            const Color(0xFFD6FFC1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );


      // body: GridView.builder(
      //   padding: const EdgeInsets.all(16),
      //   itemCount: games.length,
      //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 2, // 2 columns
      //     childAspectRatio: 0.8,
      //     mainAxisSpacing: 16,
      //     crossAxisSpacing: 16,
      //   ),
      //   itemBuilder: (context, index) {
      //     final game = games[index];
      //     return GestureDetector(
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (_) => GameStatsScreen(gameId: game['id']!),
      //           ),
      //         );
      //       },
      //       child: Card(
      //         elevation: 4,
      //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //         child: Column(
      //           children: [
      //             Expanded(
      //               child: ClipRRect(
      //                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      //                 child: Image.asset(
      //                   game['image']!,
      //                   fit: BoxFit.cover,
      //                   width: double.infinity,
      //                 ),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.all(12),
      //               child: Text(
      //                 game['name']!,
      //                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    // );
  }

  Widget _buildGameCard(
    BuildContext context,
    String name,
    String imagePath,
    Color topBgColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameStatsScreen(gameId: name)
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: topBgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Image.asset(imagePath, height: 110, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 6.0,
                right: 6.0,
                bottom: 6.0,
              ),
              child: Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

