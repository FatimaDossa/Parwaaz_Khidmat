import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../dashboard/sunshine_dashboard.dart';
import '../dashboard/butterfly_dashboard.dart';

Future<void> navigateToUserDashboard(BuildContext context) async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userType = doc['userType'];

    if (!context.mounted) return;

    if (userType == 'SUNSHINE') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SunshineDashboard()),
        (route) => false,
      );
    } else if (userType == 'BUTTERFLY') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ButterflyDashboard()),
        (route) => false,
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error navigating to dashboard: $e')),
    );
  }
}

// Add more reusable functions here
Future<void> showErrorDialog(BuildContext context, String message) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> preloadGameAssets(BuildContext context, List<String> assetPaths) async {
  for (var asset in assetPaths) {
    await precacheImage(AssetImage(asset), context);
  }
}

