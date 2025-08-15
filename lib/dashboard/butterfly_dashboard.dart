import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart'; // adjust path as needed
import '../screens/game_stats_screen.dart'; // adjust path as needed
import 'package:connectivity_plus/connectivity_plus.dart';


class ButterflyDashboard extends StatefulWidget {
  const ButterflyDashboard({super.key});

  @override
  State<ButterflyDashboard> createState() => _ButterflyDashboardState();
}

class _ButterflyDashboardState extends State<ButterflyDashboard> {
  String? username;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        errorMessage = "You are offline";
        isLoading = false;
      });
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 10));

        if (doc.exists && doc.data()!.containsKey('username')) {
          setState(() {
            username = doc['username'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Username not found";
            isLoading = false;
          });
        }
      }
    } on TimeoutException {
      setState(() {
        errorMessage = "Slow internet. Try again.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECCFF5),
      appBar: AppBar(
        title: const Text('Butterfly Dashboard'),
        actions: [
          Tooltip(
            message: 'Logout',
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorState()
                  : _buildDashboardContent(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: fetchUsername,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi ${username ?? "Player"}!',
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

                // Game Cards
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.75,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildGameCard(context, 'Back To School',
                        'assets/images/school_butterfly.png', const Color(0xFFFFF1C1)),
                    _buildGameCard(context, 'Money Maker',
                        'assets/images/money_butterfly.png', const Color(0xFFC1F1FF)),
                    _buildGameCard(context, 'Shaadi Social',
                        'assets/images/mannerism_sunshine.png', const Color(0xFFD6FFC1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(
      BuildContext context, String name, String imagePath, Color topBgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameStatsScreen(gameId: name)),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Image.asset(imagePath, height: 110, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(6.0),
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