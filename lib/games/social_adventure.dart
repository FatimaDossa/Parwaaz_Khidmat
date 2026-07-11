import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_stats_service.dart';

// ============================================================
// ENTRY POINT — this is what GameStatsScreen's gameRoutes calls
// ============================================================
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  int? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE6E6FA), Color(0xFFB4A7D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Back button — consistent with rest of the app
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Color(0xFF4B0082),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Social Adventure',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B0082),
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Learn Social Skills Through Play',
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF2F4F4F),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 25,
                        crossAxisSpacing: 25,
                        children: [
                          _buildLevelButton(1, '👋', 'Greetings'),
                          _buildLevelButton(2, '🏠', 'Public/Private'),
                          _buildLevelButton(3, '😊', 'Emotions'),
                          Container(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: ElevatedButton(
                      onPressed: selectedLevel != null
                          ? () {
                              if (selectedLevel == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Level1Screen(),
                                  ),
                                );
                              } else if (selectedLevel == 2) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Level2Screen(),
                                  ),
                                );
                              } else if (selectedLevel == 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Level3Screen(),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(320, 85),
                        backgroundColor: selectedLevel != null
                            ? const Color(0xFF9370DB)
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: selectedLevel != null ? 8 : 2,
                      ),
                      child: Text(
                        selectedLevel != null
                            ? 'START LEVEL $selectedLevel'
                            : 'SELECT A LEVEL',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: selectedLevel != null
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(int level, String emoji, String label) {
    bool isSelected = selectedLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB4A7D6), Color(0xFF87CEEB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(color: const Color(0xFF4B0082), width: 5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(emoji, style: const TextStyle(fontSize: 120)),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LEVEL 1: GREETINGS WITH SCROLLING
class Level1Screen extends StatefulWidget {
  const Level1Screen({super.key});

  @override
  State<Level1Screen> createState() => _Level1ScreenState();
}

class _Level1ScreenState extends State<Level1Screen> {
  int currentGuestIndex = 0;
  int respectMeter = 0;
  late Stopwatch stopwatch;
  Timer? timer;
  String timeDisplay = "00:00";
  int attemptNumber = 1;

  final List<Map<String, dynamic>> guests = [
    {
      'name': 'Elderly Uncle',
      'nameUrdu': 'بزرگ چچا',
      'description': 'An elderly uncle is arriving',
      'descriptionUrdu': 'بزرگ چچا آ رہے ہیں',
      'image': '👴🏽',
      'correctActions': ['salam'],
    },
    {
      'name': 'Your Teacher',
      'nameUrdu': 'آپ کی استانی',
      'description': 'Your teacher wants to greet you',
      'descriptionUrdu': 'آپ کی استانی آپ سے ملنا چاہتی ہیں',
      'image': '🧕🏽',
      'correctActions': ['salam', 'handshake'],
    },
    {
      'name': 'Female Cousin',
      'nameUrdu': 'کزن بہن',
      'description': 'Your female cousin is here',
      'descriptionUrdu': 'آپ کی کزن بہن یہاں ہے',
      'image': '🧕🏽',
      'correctActions': ['hug', 'salam'],
    },
    {
      'name': 'Elderly Grandmother',
      'nameUrdu': 'دادی اماں',
      'description': 'Your grandmother has arrived',
      'descriptionUrdu': 'آپ کی دادی اماں آ گئی ہیں',
      'image': '👵🏽',
      'correctActions': ['salam'],
    },
    {
      'name': "Friend's Mother",
      'nameUrdu': 'دوست کی امی',
      'description': "Your friend's mother greets you",
      'descriptionUrdu': 'آپ کے دوست کی امی آپ کو سلام کرتی ہیں',
      'image': '🧕🏽',
      'correctActions': ['salam', 'handshake'],
    },
    {
      'name': 'School Principal',
      'nameUrdu': 'اسکول پرنسپل',
      'description': 'The school principal is here',
      'descriptionUrdu': 'اسکول کے پرنسپل یہاں ہیں',
      'image': '👨🏽‍💼',
      'correctActions': ['salam'],
    },
  ];

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _loadAttemptNumber();
    _startTimer();
  }

  Future<void> _loadAttemptNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 1';
    List<String> existing = prefs.getStringList(key) ?? [];
    setState(() {
      attemptNumber = existing.length + 1;
    });
  }

  void _startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          int seconds = stopwatch.elapsed.inSeconds;
          int minutes = seconds ~/ 60;
          seconds = seconds % 60;
          timeDisplay =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Exit Level?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B0082),
              ),
            ),
            content: const Text(
              'Your progress will be lost. Are you sure?',
              style: TextStyle(fontSize: 20, color: Color(0xFF2F4F4F)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Stay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleAction(String action) {
    List<String> correctActions = List<String>.from(
      guests[currentGuestIndex]['correctActions'],
    );
    bool isCorrect = correctActions.contains(action);

    if (isCorrect) {
      setState(() {
        respectMeter++;
      });
      _showFeedback(true);
    } else {
      setState(() {
        if (respectMeter > 0) respectMeter--;
      });
      _showFeedback(false);
    }
  }

  void _showFeedback(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  isCorrect ? "👏" : "😕",
                  style: const TextStyle(fontSize: 70),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                isCorrect ? "Excellent!" : "Try Again!",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B0082),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isCorrect) {
                    _nextGuest();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  minimumSize: const Size(150, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isCorrect ? "Continue" : "Try Again",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextGuest() {
    if (currentGuestIndex < guests.length - 1) {
      setState(() {
        currentGuestIndex++;
      });
    } else {
      _completeLevel();
    }
  }

  void _completeLevel() async {
    stopwatch.stop();
    timer?.cancel();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 1';
    List<String> existing = prefs.getStringList(key) ?? [];

    existing.add(
      jsonEncode({
        'attemptNumber': attemptNumber,
        'time': stopwatch.elapsed.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
        'score': respectMeter,
        'totalPossible': guests.length,
        'completed': true,
        'exitedEarly': false,
      }),
    );

    await prefs.setStringList(key, existing);

    // Save to Firestore alongside local SharedPreferences tracking
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await GameStatsService().updateGamePartStats(
          gameId: 'Social Adventure',
          userId: userId,
          partId: 'level1',
          score: respectMeter.toDouble(),
          timeSpent: stopwatch.elapsed.inSeconds.toDouble(),
        );
      } catch (e) {
        debugPrint('Failed to save Social Adventure Level 1 stats: $e');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text("🎉", style: TextStyle(fontSize: 70)),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Level Complete!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0082),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "Time: $timeDisplay",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2F4F4F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Score: $respectMeter/${guests.length}",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2F4F4F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9370DB),
                    minimumSize: const Size(180, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Back to Main",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGuest = guests[currentGuestIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF0F8FF), Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          timeDisplay,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        "Progress: ${currentGuestIndex + 1}/${guests.length}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (currentGuestIndex + 1) / guests.length,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF90EE90),
                            ),
                            minHeight: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              currentGuest['image'],
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                currentGuest['description'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B0082),
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                currentGuest['descriptionUrdu'],
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B0082),
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildActionButton(
                          emoji: "🙏🏽",
                          label: "Salaam",
                          action: 'salam',
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          emoji: "🤝🏽",
                          label: "Handshake",
                          action: 'handshake',
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          emoji: "🤗",
                          label: "Hug",
                          action: 'hug',
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          emoji: "👋🏽",
                          label: "Wave",
                          action: 'wave',
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String emoji,
    required String label,
    required String action,
  }) {
    return GestureDetector(
      onTap: () => _handleAction(action),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF9370DB),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LEVEL 2: PUBLIC VS PRIVATE WITH SCROLLING
class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});

  @override
  State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  late Stopwatch stopwatch;
  Timer? timer;
  String timeDisplay = "00:00";
  int currentCardIndex = 0;
  int correctAnswers = 0;
  bool showInstructions = true;
  int attemptNumber = 1;
  late List<Map<String, dynamic>> shuffledCards;

  final List<Map<String, dynamic>> allBehaviorCards = [
    {
      'title': 'Using the Toilet',
      'titleUrdu': 'ٹوائلٹ استعمال کرنا',
      'icon': '🚽',
      'correctZone': 'private',
      'feedback': 'Correct! Using the toilet is always private.',
    },
    {
      'title': 'Showering',
      'titleUrdu': 'نہانا',
      'icon': '🚿',
      'correctZone': 'private',
      'feedback': 'Right! Showering is done in private.',
    },
    {
      'title': 'Adjusting Hijab',
      'titleUrdu': 'حجاب ٹھیک کرنا',
      'icon': '🧕🏽',
      'correctZone': 'private',
      'feedback': 'Correct! Adjust hijab privately.',
    },
    {
      'title': 'Sleeping',
      'titleUrdu': 'سونا',
      'icon': '😴',
      'correctZone': 'private',
      'feedback': 'Good! Sleeping is private.',
    },
    {
      'title': 'Changing Clothes',
      'titleUrdu': 'کپڑے بدلنا',
      'icon': '👕',
      'correctZone': 'private',
      'feedback': 'Perfect! Always change in private.',
    },
    {
      'title': 'Waving',
      'titleUrdu': 'ہاتھ ہلانا',
      'icon': '👋🏽',
      'correctZone': 'public',
      'feedback': 'Excellent! Waving is public.',
    },
    {
      'title': 'Eating',
      'titleUrdu': 'کھانا کھانا',
      'icon': '🍽️',
      'correctZone': 'public',
      'feedback': 'Great! Eating together is public.',
    },
    {
      'title': 'Talking',
      'titleUrdu': 'بات کرنا',
      'icon': '💬',
      'correctZone': 'public',
      'feedback': 'Perfect! Talking is public.',
    },
    {
      'title': 'Playing Games',
      'titleUrdu': 'کھیل کھیلنا',
      'icon': '🎮',
      'correctZone': 'public',
      'feedback': 'Excellent! Playing is public.',
    },
    {
      'title': 'Greeting Someone',
      'titleUrdu': 'کسی کو سلام کرنا',
      'icon': '🤝🏽',
      'correctZone': 'public',
      'feedback': 'Correct! Greeting is public.',
    },
  ];

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    shuffledCards = List.from(allBehaviorCards)..shuffle(Random());
    _loadAttemptNumber();
    _startTimer();
  }

  Future<void> _loadAttemptNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 2';
    List<String> existing = prefs.getStringList(key) ?? [];
    setState(() {
      attemptNumber = existing.length + 1;
    });
  }

  void _startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          int seconds = stopwatch.elapsed.inSeconds;
          int minutes = seconds ~/ 60;
          seconds = seconds % 60;
          timeDisplay =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Exit Level?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B0082),
              ),
            ),
            content: const Text(
              'Your progress will be lost. Are you sure?',
              style: TextStyle(fontSize: 20, color: Color(0xFF2F4F4F)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Stay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleZoneSelection(String selectedZone) {
    bool isCorrect =
        selectedZone == shuffledCards[currentCardIndex]['correctZone'];

    if (isCorrect) {
      setState(() {
        correctAnswers++;
      });
    } else {
      setState(() {
        if (correctAnswers > 0) correctAnswers--;
      });
    }

    _showFeedback(isCorrect, shuffledCards[currentCardIndex]['feedback']);
  }

  void _showFeedback(bool isCorrect, String feedbackMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  isCorrect ? "✅" : "❌",
                  style: const TextStyle(fontSize: 70),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                isCorrect ? "Correct!" : "Not quite right",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B0082),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                feedbackMessage,
                style: const TextStyle(fontSize: 22, color: Color(0xFF2F4F4F)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _nextCard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  minimumSize: const Size(150, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextCard() {
    if (currentCardIndex < shuffledCards.length - 1) {
      setState(() {
        currentCardIndex++;
      });
    } else {
      _completeLevel();
    }
  }

  void _completeLevel() async {
    stopwatch.stop();
    timer?.cancel();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 2';
    List<String> existing = prefs.getStringList(key) ?? [];

    existing.add(
      jsonEncode({
        'attemptNumber': attemptNumber,
        'time': stopwatch.elapsed.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
        'score': correctAnswers,
        'totalPossible': shuffledCards.length,
        'completed': true,
        'exitedEarly': false,
      }),
    );

    await prefs.setStringList(key, existing);

    // Save to Firestore alongside local SharedPreferences tracking
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await GameStatsService().updateGamePartStats(
          gameId: 'Social Adventure',
          userId: userId,
          partId: 'level2',
          score: correctAnswers.toDouble(),
          timeSpent: stopwatch.elapsed.inSeconds.toDouble(),
        );
      } catch (e) {
        debugPrint('Failed to save Social Adventure Level 2 stats: $e');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text("🎉", style: TextStyle(fontSize: 70)),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Level 2 Complete!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0082),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "Time: $timeDisplay",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2F4F4F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Score: $correctAnswers/${shuffledCards.length}",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2F4F4F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9370DB),
                    minimumSize: const Size(180, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Back to Main",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showInstructions) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF0F8FF), Color(0xFFE6E6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(30),
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "📋",
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Select if each activity is PUBLIC or PRIVATE",
                        style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFF2F4F4F),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showInstructions = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9370DB),
                          minimumSize: const Size(180, 65),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(fontSize: 26, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentCard = shuffledCards[currentCardIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF0F8FF), Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          timeDisplay,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        "${currentCardIndex + 1}/${shuffledCards.length}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (currentCardIndex + 1) / shuffledCards.length,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF90EE90),
                            ),
                            minHeight: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentCard['icon'],
                                style: const TextStyle(fontSize: 80),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                currentCard['title'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B0082),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                currentCard['titleUrdu'],
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B0082),
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        GestureDetector(
                          onTap: () => _handleZoneSelection('public'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: const Color(0xFF87CEEB),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "🏛️",
                                  style: TextStyle(fontSize: 60),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "PUBLIC",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _handleZoneSelection('private'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9370DB),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "🚪",
                                  style: TextStyle(fontSize: 60),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "PRIVATE",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// LEVEL 3: EMOTIONS & SOCIAL SITUATIONS
class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen>
    with TickerProviderStateMixin {
  late Stopwatch stopwatch;
  Timer? timer;
  String timeDisplay = "00:00";
  int currentScenarioIndex = 0;
  int earnedStars = 0;
  int attemptNumber = 1;

  late AnimationController _animationController;
  late Animation<double> _starAnimation;

  final List<Map<String, dynamic>> scenarios = [
    {
      'title': 'Spilled Drink',
      'description': 'A child spills their drink',
      'scene': '🧒🏽🥤💧',
      'options': [
        {'text': 'Comfort & Help', 'icon': '🧻😊', 'isCorrect': true},
        {'text': 'Laugh', 'icon': '😂', 'isCorrect': false},
        {'text': 'Walk Away', 'icon': '🚶', 'isCorrect': false},
      ],
      'correctFeedback': 'Perfect! You showed kindness.',
    },
    {
      'title': 'Sad Cousin',
      'description': 'Your cousin looks sad and alone',
      'scene': '😢🧕🏽',
      'options': [
        {'text': 'Sit & Talk', 'icon': '🤗💬', 'isCorrect': true},
        {'text': 'Ignore', 'icon': '🎮', 'isCorrect': false},
        {'text': 'Tell Others', 'icon': '🗣️', 'isCorrect': false},
      ],
      'correctFeedback': 'Excellent! You showed empathy.',
    },
    {
      'title': 'Kids Arguing',
      'description': 'Two kids are arguing loudly',
      'scene': '👦🏽🧕🏽💢',
      'options': [
        {'text': 'Get Adult', 'icon': '👨‍👩‍👧‍👦', 'isCorrect': true},
        {'text': 'Join Argument', 'icon': '😤', 'isCorrect': false},
        {'text': 'Watch & Laugh', 'icon': '😆', 'isCorrect': false},
      ],
      'correctFeedback': 'Smart! Getting help was right.',
    },
    {
      'title': 'Confused Elder',
      'description': 'An elderly person looks confused',
      'scene': '👵🏽❓',
      'options': [
        {'text': 'Offer Help', 'icon': '🤝🏽', 'isCorrect': true},
        {'text': 'Stare', 'icon': '👀', 'isCorrect': false},
        {'text': 'Ignore', 'icon': '😐', 'isCorrect': false},
      ],
      'correctFeedback': 'Great! You showed respect.',
    },
    {
      'title': 'Loud Child',
      'description': 'A child is making noise during a talk',
      'scene': '👶🏽📢',
      'options': [
        {'text': 'Gentle Reminder', 'icon': '🤫', 'isCorrect': true},
        {'text': 'Shout at Them', 'icon': '😡', 'isCorrect': false},
        {'text': 'Make Noise Too', 'icon': '🔊', 'isCorrect': false},
      ],
      'correctFeedback': 'Perfect! You handled it calmly.',
    },
    {
      'title': 'Left Out',
      'description': 'A child is sitting alone while others play',
      'scene': '😔🧕🏽',
      'options': [
        {'text': 'Invite to Join', 'icon': '🤗', 'isCorrect': true},
        {'text': 'Ignore', 'icon': '🙄', 'isCorrect': false},
        {'text': 'Tell to Leave', 'icon': '👋', 'isCorrect': false},
      ],
      'correctFeedback': 'Beautiful! You showed inclusion.',
    },
  ];

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _loadAttemptNumber();
    _startTimer();
  }

  Future<void> _loadAttemptNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 3';
    List<String> existing = prefs.getStringList(key) ?? [];
    setState(() {
      attemptNumber = existing.length + 1;
    });
  }

  void _startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          int seconds = stopwatch.elapsed.inSeconds;
          int minutes = seconds ~/ 60;
          seconds = seconds % 60;
          timeDisplay =
              "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Exit Level?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B0082),
              ),
            ),
            content: const Text(
              'Your progress will be lost. Are you sure?',
              style: TextStyle(fontSize: 20, color: Color(0xFF2F4F4F)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Stay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleOptionSelected(Map<String, dynamic> option) {
    bool isCorrect = option['isCorrect'];

    if (isCorrect) {
      earnedStars++;
      _showStarFeedback(scenarios[currentScenarioIndex]['correctFeedback']);
    } else {
      setState(() {
        if (earnedStars > 0) earnedStars--;
      });
      _showWrongFeedback();
    }
  }

  void _showStarFeedback(String feedback) {
    _animationController.forward().then((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _starAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _starAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6FA),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFFB4A7D6),
                            width: 4,
                          ),
                        ),
                        child: const Text(
                          "⭐",
                          style: TextStyle(fontSize: 80),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  "Kindness Star Earned!",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0082),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2F4F4F),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _animationController.reset();
                    _nextScenario();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9370DB),
                    minimumSize: const Size(170, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 26, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showWrongFeedback() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: const Text("😕", style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Try Again!",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B0082),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Think about what would help most.",
                style: TextStyle(fontSize: 22, color: Color(0xFF2F4F4F)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  minimumSize: const Size(150, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Try Again",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextScenario() {
    if (currentScenarioIndex < scenarios.length - 1) {
      setState(() {
        currentScenarioIndex++;
      });
    } else {
      _completeLevel();
    }
  }

  void _completeLevel() async {
    stopwatch.stop();
    timer?.cancel();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'attempts_Level 3';
    List<String> existing = prefs.getStringList(key) ?? [];

    existing.add(
      jsonEncode({
        'attemptNumber': attemptNumber,
        'time': stopwatch.elapsed.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
        'score': earnedStars,
        'totalPossible': scenarios.length,
        'completed': true,
        'exitedEarly': false,
      }),
    );

    await prefs.setStringList(key, existing);

    // Save to Firestore alongside local SharedPreferences tracking
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await GameStatsService().updateGamePartStats(
          gameId: 'Social Adventure',
          userId: userId,
          partId: 'level3',
          score: earnedStars.toDouble(),
          timeSpent: stopwatch.elapsed.inSeconds.toDouble(),
        );
      } catch (e) {
        debugPrint('Failed to save Social Adventure Level 3 stats: $e');
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text("🎉", style: TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Level 3 Complete!",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0082),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Text(
                  "Time: $timeDisplay",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Color(0xFF2F4F4F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Stars: ",
                      style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    Text(
                      "$earnedStars/${scenarios.length} ⭐",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0082),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9370DB),
                    minimumSize: const Size(190, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Back to Main",
                    style: TextStyle(fontSize: 26, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScenario = scenarios[currentScenarioIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF0F8FF), Color(0xFFE6E6FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (await _onWillPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          timeDisplay,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B0082),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Stars: ",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082),
                        ),
                      ),
                      Text(
                        "$earnedStars/${scenarios.length} ⭐",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  currentScenario['scene'],
                                  style: const TextStyle(fontSize: 100),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  currentScenario['title'],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4B0082),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  currentScenario['description'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFF2F4F4F),
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Text(
                            "What should you do?",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B0082),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...currentScenario['options']
                              .map<Widget>((option) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15),
                                    child: GestureDetector(
                                      onTap: () => _handleOptionSelected(option),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFB4A7D6),
                                              Color(0xFF87CEEB)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  option['icon'],
                                                  style: const TextStyle(
                                                      fontSize: 40),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Text(
                                                option['text'],
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}