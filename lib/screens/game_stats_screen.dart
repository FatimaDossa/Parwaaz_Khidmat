import 'package:flutter/material.dart';
import '../games/emotion_game.dart';
import '../games/school_game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameStatsScreen extends StatelessWidget {
  final String gameId;

  GameStatsScreen({super.key, required this.gameId});

  final Map<String, WidgetBuilder> gameRoutes = {
      'emotion_game': (_) => const GameStartScreenS(),
      'classroom_game': (_) => const GameStartScreenB(),
      // Add more mappings
    };

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final statsRef = FirebaseFirestore.instance
        .collection('game_stats')
        .doc(gameId)
        .collection('users')
        .doc(userId);

    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5), // lavender
      appBar: AppBar(
        title: Text('$gameId Stats'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: statsRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No stats found yet."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final parts = data['parts'] as Map<String, dynamic>? ?? {};

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: parts.entries.map((entry) {
                    final partId = entry.key;
                    final stats = entry.value as Map<String, dynamic>;

                    final avgScore = stats['avgScore']?.toDouble() ?? 0;
                    final avgTime = stats['avgTime']?.toDouble() ?? 0;
                    final timesCompleted = stats['timesCompleted'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text("Part: $partId"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text("📊 Average Score: ${avgScore.toStringAsFixed(1)}"),
                            Text("⏱️ Average Time: ${avgTime.toStringAsFixed(1)} seconds"),
                            Text("🔁 Times Completed: $timesCompleted"),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final builder = gameRoutes[gameId];
                        if (builder != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: builder),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Game not available')),
                          );
                        }
                      },
                      child: const Text('Play'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}


// class GameStatsScreen extends StatelessWidget {
//   final String gameId;
//   final String gameName;

//   const GameStatsScreen({
//     super.key,
//     required this.gameId,
//     required this.gameName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Replace with real stats from Firestore later
//     final Map<String, dynamic> mockStats = {
//       'avgTime': '1m 30s',
//       'avgScore': 80,
//       'timesPlayed': 5,
//       'levels': {
//         1: 3,
//         2: 2,
//       },
//     };

//     final Map<String, WidgetBuilder> gameRoutes = {
//       'emotion_game': (_) => const GameStartScreenS(),
//       'classroom_game': (_) => const GameStartScreenB(),
//       // Add more mappings
//     };

//     return Scaffold(
//       backgroundColor: const Color(0xFFECCFF5), // lavender
//       appBar: AppBar(title: Text('$gameName Stats')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Average Time: ${mockStats['avgTime']}'),
//             Text('Average Score: ${mockStats['avgScore']}'),
//             Text('Total Plays: ${mockStats['timesPlayed']}'),
//             const SizedBox(height: 16),
//             const Text('Levels Played:', style: TextStyle(fontWeight: FontWeight.bold)),
//             ...mockStats['levels'].entries.map<Widget>((entry) => Text('Level ${entry.key}: ${entry.value} times')),

//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Back'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     final builder = gameRoutes[gameId];
//                     if (builder != null) {
//                       Navigator.push(context, MaterialPageRoute(builder: builder));
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Game not available')),
//                       );
//                     }
//                   },
//                   child: const Text('Play'),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
