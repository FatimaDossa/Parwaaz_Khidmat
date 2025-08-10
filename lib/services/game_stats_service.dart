import 'package:cloud_firestore/cloud_firestore.dart';

class GameStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateGamePartStats({
    required String gameId,
    required String userId,
    required String partId, // e.g. 'part1', 'part2', 'part3'
    required double score,
    required double timeSpent,
  }) async {
    final docRef = _firestore
        .collection('game_stats')
        .doc(gameId)
        .collection('users')
        .doc(userId);

    final docSnapshot = await docRef.get();

    final partPath = 'parts.$partId';

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final partData = (data?['parts'] ?? {})[partId] ?? {};

      final prevScore = (partData['avgScore'] ?? 0.0).toDouble();
      final prevTime = (partData['avgTime'] ?? 0.0).toDouble();
      final prevCount = (partData['timesCompleted'] ?? 0).toInt();
      final newCount = prevCount + 1;

      await docRef.update({
        '$partPath.avgScore': newCount > 0 ? (prevScore + score) / newCount : score,
        '$partPath.avgTime': newCount > 0 ? (prevTime + timeSpent) / newCount : score,
        '$partPath.timesCompleted': newCount,
        'lastPlayed': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.set({
        'parts': {
          partId: {
            'avgScore': score,
            'avgTime': timeSpent,
            'timesCompleted': 1,
          }
        },
        'lastPlayed': FieldValue.serverTimestamp(),
      });
    }
  }
}
