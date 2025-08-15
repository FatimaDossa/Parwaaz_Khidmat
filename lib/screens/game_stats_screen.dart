// import 'package:flutter/material.dart';
// import '../games/emotion_game.dart';
// import '../games/school_game.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GameStatsScreen extends StatelessWidget {
//   final String gameId;

//   GameStatsScreen({super.key, required this.gameId});

//   final Map<String, WidgetBuilder> gameRoutes = {
//     // sunshine games
//       'Learning Ninja': (_) => const GameStartScreenS(),
//       'Emotion Explorer': (_) => const GameStartScreenS(),
//       'Mannerism Master': (_) => const GameStartScreenS(),
//     // butterfly games
//       'Back To School': (_) => const GameStartScreenB(),
//       // Add more mappings
//     };

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final statsRef = FirebaseFirestore.instance
//         .collection('game_stats')
//         .doc(gameId)
//         .collection('users')
//         .doc(userId);

//     return Scaffold(
//       backgroundColor: const Color(0xFFECCFF5), // lavender
//       appBar: AppBar(
//         title: Text('$gameId Stats'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Column(
//       children: [
//         Expanded(
//           child:
//             FutureBuilder<DocumentSnapshot>(
//               future: statsRef.get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const Center(child: Text("No stats found yet.", style: TextStyle(fontSize: 35),),);
//                 }

//                 final data = snapshot.data!.data() as Map<String, dynamic>;
//                 final parts = data['parts'] as Map<String, dynamic>? ?? {};

//                 return Column(
//                   children: [
//                     Expanded(
//                       child: ListView(
//                         padding: const EdgeInsets.all(16),
//                         children: parts.entries.map((entry) {
//                           final partId = entry.key;
//                           final stats = entry.value as Map<String, dynamic>;

//                           final avgScore = stats['avgScore']?.toDouble() ?? 0;
//                           final avgTime = stats['avgTime']?.toDouble() ?? 0;
//                           final timesCompleted = stats['timesCompleted'] ?? 0;

//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ListTile(
//                               title: Text("Part: $partId", style: TextStyle(fontSize: 20)),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(height: 12),
//                                   Text("📊 Average Score: ${avgScore.toStringAsFixed(1)}", style: TextStyle(fontSize: 20)),
//                                   Text("⏱️ Average Time: ${avgTime.toStringAsFixed(1)} seconds", style: TextStyle(fontSize: 20)),
//                                   Text("🔁 Times Completed: $timesCompleted", style: TextStyle(fontSize: 20)),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),]
//                 );
//               },
//             ),
//           ),

//           // ✅ These buttons are always visible
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF39C50), 
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: const Text(
//                       'Back',
//                       style: TextStyle(fontSize: 22),
//                     ),
//                   ),

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
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF39C50),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                   child: const Text('Play', style: TextStyle(fontSize: 22)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }


// // class GameStatsScreen extends StatelessWidget {
// //   final String gameId;
// //   final String gameName;

// //   const GameStatsScreen({
// //     super.key,
// //     required this.gameId,
// //     required this.gameName,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     // Replace with real stats from Firestore later
// //     final Map<String, dynamic> mockStats = {
// //       'avgTime': '1m 30s',
// //       'avgScore': 80,
// //       'timesPlayed': 5,
// //       'levels': {
// //         1: 3,
// //         2: 2,
// //       },
// //     };

// //     final Map<String, WidgetBuilder> gameRoutes = {
// //       'emotion_game': (_) => const GameStartScreenS(),
// //       'classroom_game': (_) => const GameStartScreenB(),
// //       // Add more mappings
// //     };

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFECCFF5), // lavender
// //       appBar: AppBar(title: Text('$gameName Stats')),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('Average Time: ${mockStats['avgTime']}'),
// //             Text('Average Score: ${mockStats['avgScore']}'),
// //             Text('Total Plays: ${mockStats['timesPlayed']}'),
// //             const SizedBox(height: 16),
// //             const Text('Levels Played:', style: TextStyle(fontWeight: FontWeight.bold)),
// //             ...mockStats['levels'].entries.map<Widget>((entry) => Text('Level ${entry.key}: ${entry.value} times')),

// //             const Spacer(),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 OutlinedButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   child: const Text('Back'),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     final builder = gameRoutes[gameId];
// //                     if (builder != null) {
// //                       Navigator.push(context, MaterialPageRoute(builder: builder));
// //                     } else {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(content: Text('Game not available')),
// //                       );
// //                     }
// //                   },
// //                   child: const Text('Play'),
// //                 )
// //               ],
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../games/emotion_game.dart';
import '../games/school_game.dart';

class GameStatsScreen extends StatelessWidget {
  final String gameId;

  GameStatsScreen({super.key, required this.gameId});

  final Map<String, WidgetBuilder> gameRoutes = {
    // sunshine games
    'Learning Ninja': (_) => const GameStartScreenS(),
    'Emotion Explorer': (_) => const GameStartScreenS(),
    'Mannerism Master': (_) => const GameStartScreenS(),
    // butterfly games
    'Back To School': (_) => const GameStartScreenB(),
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
      backgroundColor: const Color(0xFFECCFF5),
      appBar: AppBar(
        title: Text('$gameId Stats'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: statsRef.get(const GetOptions(source: Source.cache))
                  .then((cachedDoc) async {
                // If cached data is empty, try server
                if (!cachedDoc.exists) {
                  return await statsRef
                      .get(const GetOptions(source: Source.server))
                      .timeout(const Duration(seconds: 5));
                }
                return cachedDoc;
              }).catchError((e) {
                debugPrint("Error fetching game stats: $e");
                throw e; // rethrow for builder to handle
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "⚠ Error loading stats.\n${snapshot.error}",
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "No stats found yet.",
                      style: TextStyle(fontSize: 35),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final parts = data['parts'] as Map<String, dynamic>? ?? {};

                return ListView(
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
                        title: Text(
                          "Part: $partId",
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              "📊 Average Score: ${avgScore.toStringAsFixed(1)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              "⏱️ Average Time: ${avgTime.toStringAsFixed(1)} seconds",
                              style: const TextStyle(fontSize: 20),
                            ),
                            Text(
                              "🔁 Times Completed: $timesCompleted",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Back', style: TextStyle(fontSize: 22)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Play', style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
