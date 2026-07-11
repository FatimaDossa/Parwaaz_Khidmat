import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_stats_service.dart';
import '../utils/helper_functions.dart';

enum GamePart { ordering, brushing }

late DateTime partStartTime;
void startPartTimer() {
  partStartTime = DateTime.now();
}

void stopPartTimer(void Function(double time) onDone) {
  final time = DateTime.now().difference(partStartTime).inSeconds.toDouble();
  onDone(time);
}

class GoodHabitHero extends StatelessWidget {
  const GoodHabitHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'Good Habit Hero',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // ðŸŒ„ Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/goodhabitherobg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ðŸ“¦ Content over the background
          Container(
            color: Colors.white.withOpacity(0.50), // Optional soft overlay
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose a Habit to Practice!",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CustomGameButton(
                  label: "🪥 Brushing Routine",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BrushingGame()),
                    );
                  },
                ),

                const SizedBox(height: 20),
                CustomGameButton(
                  label: "🍽️ Table Manners",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TableMannersGame(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomGameButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CustomGameButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

enum GamePhase { ordering, brushing }

class BrushingGame extends StatefulWidget {
  const BrushingGame({super.key});

  @override
  State<BrushingGame> createState() => _BrushingGameState();
}

class DraggableStep extends StatelessWidget {
  final String imagePath;
  final String label;
  final String stepId;

  const DraggableStep({
    super.key,
    required this.imagePath,
    required this.label,
    required this.stepId,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: stepId,
      feedback: Image.asset(imagePath, width: 80),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: Image.asset(imagePath, width: 80),
      ),
      child: Image.asset(imagePath, width: 80),
    );
  }
}

class _BrushingGameState extends State<BrushingGame>
    with TickerProviderStateMixin {
  static const String _gameId = 'Good Habit Hero';
  static const String _orderingPartId = 'Ordering';
  static const String _brushingPartId = 'Brushing';

  // ===== STATS =====
  bool orderingCompleted = false;
  bool _orderingStatsSaved = false;
  bool _brushingStatsSaved = false;
  Timer? _timer;
  DateTime? _partStartTime;

  double orderingTime = 0;
  double brushingTime = 0;

  double orderingScore = 0;
  double brushingScore = 0;
  double liveTime = 0;

  void startTimer() {
    _partStartTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        liveTime = DateTime.now()
            .difference(_partStartTime!)
            .inSeconds
            .toDouble();
      });
    });
  }

  double stopTimer() {
    _timer?.cancel();
    if (_partStartTime == null) return liveTime;
    return DateTime.now().difference(_partStartTime!).inSeconds.toDouble();
  }

  void _recalculateOrderingScore() {
    int correctCount = 0;
    for (int i = 0; i < correctOrder.length; i++) {
      if (droppedSteps[i] == correctOrder[i]) {
        correctCount++;
      }
    }
    orderingScore = (correctCount * 10).toDouble();
  }

  // ================= PHASE CONTROL =================
  GamePhase currentPhase = GamePhase.ordering;

  late AnimationController _bubbleController;
  late Animation<double> _bubbleOpacity;
  late Animation<double> _bubbleScale;
  late Animation<Offset> _bubbleMove;

  late AnimationController _controller;
  late Animation<Offset> _orderSlide;
  late Animation<Offset> _brushingSlide;

  // ================= ORDERING GAME =================
  final List<String> correctOrder = ['toothbrush', 'toothpaste', 'brushing'];
  final Map<int, String?> droppedSteps = {0: null, 1: null, 2: null};

  final List<Map<String, String>> steps = [
    {'id': 'toothbrush', 'image': 'assets/images/toothbrush.png'},
    {'id': 'toothpaste', 'image': 'assets/images/toothpaste.png'},
    {'id': 'brushing', 'image': 'assets/images/brushing.png'},
  ]..shuffle();

  // ================= BRUSHING GAME (UPDATED) =================
  final GlobalKey _teethKey = GlobalKey();

  // Germ positions (adjust these based on your teeth image)
  List<GermData> germs = [
    GermData(id: 0, position: Offset(0.21, 0.30)),
    GermData(id: 1, position: Offset(0.50, 0.20)),
    GermData(id: 2, position: Offset(0.70, 0.35)),
    GermData(id: 3, position: Offset(0.23, 0.59)),
    GermData(id: 5, position: Offset(0.68, 0.62)),
    GermData(id: 6, position: Offset(0.38, 0.73)),
    GermData(id: 7, position: Offset(0.55, 0.75)),
  ];

  Offset? brushPosition;
  bool showCelebration = false;

  @override
  void initState() {
    super.initState();
    startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bubbleOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bubbleController, curve: Curves.easeIn));

    _bubbleScale = Tween<double>(begin: 0.6, end: 1.1).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutBack),
    );

    _bubbleMove = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.15))
        .animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeOut),
        );

    _orderSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _brushingSlide = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  // ================= CHECK ORDER =================
  void checkResult() {
    bool correct = true;
    for (int i = 0; i < 3; i++) {
      if (droppedSteps[i] != correctOrder[i]) {
        correct = false;
        break;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(
          correct ? 'Great Job!' : 'Try Again',
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          correct
              ? 'You placed all steps correctly.'
              : 'Some steps are in the wrong order.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (correct && !orderingCompleted) {
                orderingCompleted = true;
                await completeOrdering();
              }
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPartCompleteDialog({
    required String title,
    required VoidCallback onNext,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (_) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins()),
        content: Text(
          'You successfully completed this part! Tap "Next" to continue.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: onNext,
            child: Text(
              'Next',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (_) => AlertDialog(
        title: Text('Congratulations!', style: GoogleFonts.poppins()),
        content: Text(
          'You have completed all the parts of the game! Well done!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GoodHabitHero()),
              );
            },
            child: Text('OK', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> completeOrdering() async {
    orderingTime = stopTimer();
    await _saveOrderingStatsIfNeeded();

    _controller.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      currentPhase = GamePhase.brushing;
      liveTime = 0;
    });
    startTimer();
  }

  Future<void> _saveOrderingStatsIfNeeded() async {
    if (!orderingCompleted || _orderingStatsSaved) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await GameStatsService().updateGamePartStats(
      gameId: _gameId,
      userId: user.uid,
      partId: _orderingPartId,
      score: orderingScore,
      timeSpent: orderingTime,
    );
    _orderingStatsSaved = true;
  }

  Future<bool> _onWillPop() async {
    // If user leaves from brushing before finishing brushing,
    // preserve already-completed ordering stats.
    if (currentPhase == GamePhase.brushing) {
      await _saveOrderingStatsIfNeeded();
    }
    return true;
  }

  void completeBrushing() async {
    if (_brushingStatsSaved) return;
    brushingTime = stopTimer();

    await _saveOrderingStatsIfNeeded();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showFinalDialog();
      return;
    }

    await GameStatsService().updateGamePartStats(
      gameId: _gameId,
      userId: user.uid,
      partId: _brushingPartId,
      score: brushingScore,
      timeSpent: brushingTime,
    );
    _brushingStatsSaved = true;

    _showFinalDialog();
  }
  // ================= CHECK BRUSH COLLISION =================
  void checkGermCollision(Offset globalPosition) {
    final RenderBox? teethBox =
        _teethKey.currentContext?.findRenderObject() as RenderBox?;

    if (teethBox == null) return;

    final localPosition = teethBox.globalToLocal(globalPosition);
    final size = teethBox.size;

    final normalizedX = localPosition.dx / size.width;
    final normalizedY = localPosition.dy / size.height;

    setState(() {
      for (var germ in germs) {
        if (germ.state == GermState.dirty) {
          final distance =
              (germ.position - Offset(normalizedX, normalizedY)).distance;

          if (distance < 0.08) {
            // 1ï¸âƒ£ show bubbles
            germ.state = GermState.bubbling;

            // 2ï¸âƒ£ after bubbles â†’ clean
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              setState(() {
                if (germ.state == GermState.bubbling) {
                  germ.state = GermState.clean;
                  brushingScore += 10;
                }

                if (germs.every((g) => g.state == GermState.clean) &&
                    !showCelebration) {
                  showCelebration = true;
                  _timer?.cancel();
                  _bubbleController.forward(from: 0);
                  completeBrushing();
                }
              });
            });
          }
        }
      }
    });
  }
  // // ================= SAVE STATS =================
  // void saveBrushingStats() async {
  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId != null) {
  //     await GameStatsService().updateGamePartStats(
  //       gameId: _gameId,
  //       userId: userId,
  //       partId: 'brushing',
  //       score: score,
  //       timeSpent: timeSpent,
  //     );
  //   }
  // }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: Text(
            "BRUSHING ROUTINE",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  "assets/images/brush.png",
                  fit: BoxFit.cover, // Ensures full coverage
                ),
              ),
            ),

            SlideTransition(position: _orderSlide, child: _orderingUI()),
            if (currentPhase == GamePhase.brushing)
              SlideTransition(position: _brushingSlide, child: _brushingUI()),
          ],
        ),
      ),
    );
  }

  // ================= ORDERING UI =================
  Widget _orderingUI() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Drag the steps into correct order',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final stepId = droppedSteps[index];
                final Color feedbackColor = stepId != null
                    ? (stepId == correctOrder[index]
                          ? Colors.green
                          : Colors.red)
                    : Colors.grey;

                return DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      droppedSteps[index] = data;
                      _recalculateOrderingScore();
                    });
                  },
                  builder: (_, __, ___) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: feedbackColor.withOpacity(0.3),
                      child: stepId != null
                          ? Image.asset(
                              'assets/images/$stepId.png',
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Text(
                                "Drop here",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: DraggableStep(
                        imagePath: step['image']!,
                        label: step['id']!,
                        stepId: step['id']!,
                      ),
                    ),
                  )
                  .toList(),
            ),
            Text(
              "⭐ Score: ${orderingScore.toInt()}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "⏱️ Time: ${liveTime.toInt()} s",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: checkResult,

              child: Text(
                "Check",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BRUSHING UI =================
  Widget _brushingUI() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        // Teeth size adapts to screen
        final double teethSize =
            (maxWidth < maxHeight ? maxWidth : maxHeight) * 0.75;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Teeth image
                    SizedBox(
                      width: teethSize,
                      height: teethSize,
                      child: Image.asset(
                        'assets/images/teeth_clean.png',
                        key: _teethKey,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Germs
                    ...germs.map((germ) {
                      if (germ.state == GermState.clean) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        left: germ.position.dx * teethSize,
                        top: germ.position.dy * teethSize,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: germ.state == GermState.dirty
                              ? Image.asset(
                                  'assets/images/bacteria.png',
                                  key: const ValueKey('bacteria'),
                                  width: teethSize * 0.08,
                                )
                              : Image.asset(
                                  'assets/images/bubbles.png',
                                  key: const ValueKey('bubbles'),
                                  width: teethSize * 0.12,
                                ),
                        ),
                      );
                    }),

                    // Celebration bubbles
                    if (showCelebration)
                      SlideTransition(
                        position: _bubbleMove,
                        child: FadeTransition(
                          opacity: _bubbleOpacity,
                          child: ScaleTransition(
                            scale: _bubbleScale,
                            child: Lottie.asset(
                              'assets/images/Sparkle Stars.json',
                              width: teethSize * 0.9,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Draggable toothbrush
                Draggable<String>(
                  data: 'brush',
                  onDragUpdate: (details) {
                    checkGermCollision(details.globalPosition);
                  },
                  feedback: Image.asset(
                    'assets/images/toothbrush2.png',
                    width: teethSize * 0.25,
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      'assets/images/toothbrush2.png',
                      width: teethSize * 0.25,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/toothbrush2.png',
                    width: teethSize * 0.25,
                  ),
                ),

                const SizedBox(height: 16),

                if (showCelebration)
                  Text(
                    '🎉 All Clean! Great Job! 🎉',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  "⭐ Score: ${brushingScore.toInt()}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "⏱️ Time: ${liveTime.toInt()} s",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.teal,
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                //   ),
                //   onPressed: resetGame,
                //   child: Text(
                //     "Play Again",
                //     style: GoogleFonts.poppins(
                //       color: Colors.white,
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= GERM DATA CLASS =================
enum GermState { dirty, bubbling, clean }

class GermData {
  final int id;
  final Offset position; // normalized
  GermState state;

  GermData({
    required this.id,
    required this.position,
    this.state = GermState.dirty,
  });
}

class TableMannersGame extends StatefulWidget {
  const TableMannersGame({super.key});

  @override
  State<TableMannersGame> createState() => _TableMannersGameState();
}

class _TableMannersGameState extends State<TableMannersGame> {
  static const String _gameId = 'Good Habit Hero';
  static const String _tableMannersPartId = 'Table Manners';
  Timer? _timer;
  DateTime? _partStartTime;

  double timeSpent = 0;
  double liveTime = 0;
  double score = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _partStartTime = DateTime.now();
    liveTime = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _partStartTime == null) return;
      setState(() {
        liveTime = DateTime.now()
            .difference(_partStartTime!)
            .inSeconds
            .toDouble();
      });
    });
  }

  double stopTimer() {
    _timer?.cancel();
    if (_partStartTime == null) return liveTime;
    return DateTime.now().difference(_partStartTime!).inSeconds.toDouble();
  }

  int currentQuestion = 0;
  bool? isCorrect;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'How should you sit at the table?',
      'options': [
        {'text': 'Sit properly', 'video': 'assets/images/sit_good.mp4'},
        {'text': 'Lie on the table', 'video': 'assets/images/sit_bad.mp4'},
      ],
      'correctIndex': 0,
    },
    {
      'question': 'Choose the correct way to eat.',
      'options': [
        {'text': 'Use hands only', 'video': 'assets/images/eat_bad.mp4'},
        {'text': 'Use spoon or fork', 'video': 'assets/images/eat_good.mp4'},
      ],
      'correctIndex': 1,
    },
    {
      'question': 'What should you NOT do?',
      'options': [
        {'text': 'Talk with full mouth', 'video': 'assets/images/talk_bad.mp4'},
        {'text': 'Chew quietly', 'video': 'assets/images/chew_good.mp4'},
      ],
      'correctIndex': 0,
    },
    {
      'question': 'What do you say after getting food?',
      'options': [
        {'text': 'Thank you', 'video': 'assets/images/thankyou.mp4'},
        {'text': 'Nothing', 'video': 'assets/images/nothing.mp4'},
      ],
      'correctIndex': 0,
    },
    {
      'question': 'What should you do after eating?',
      'options': [
        {'text': 'Leave the mess', 'video': 'assets/images/leave_mess.mp4'},
        {'text': 'Clean up', 'video': 'assets/images/clean_up.mp4'},
      ],
      'correctIndex': 1,
    },
  ];

  void checkAnswer(int selectedIndex) async {
    setState(() {
      isCorrect = selectedIndex == questions[currentQuestion]['correctIndex'];
      if (isCorrect!) {
        score += 10; // ⭐ +10 per correct answer
      }
    });

    if (isCorrect == false && await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isCorrect! ? 'Correct!' : 'Oops!',
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          isCorrect! ? 'Good manners!' : 'That is not the polite choice.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (currentQuestion < questions.length - 1) {
                setState(() {
                  currentQuestion++;
                  isCorrect = null;
                });
                return;
              }

              timeSpent = stopTimer();

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await GameStatsService().updateGamePartStats(
                  gameId: _gameId,
                  userId: user.uid,
                  partId: _tableMannersPartId,
                  score: score,
                  timeSpent: timeSpent,
                );
              }
              if (!mounted) return;
              _showCompletionDialog();
            },
            child: Text(
              'Next',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Completed!', style: GoogleFonts.poppins()),
        content: Text(
          'You finished all table manners questions.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await navigateToUserDashboard(context);
            },
            child: Text(
              'Yay! 🎉',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          "TABLE MANNERS",
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.45,
              child: Image.asset("assets/images/dinner.jpg", fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // QUESTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "⭐ Score: ${score.toInt()}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "⏱️ Time: ${liveTime.toInt()} s",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    questions[currentQuestion]['question'],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // OPTIONS (TAKE REMAINING SPACE)
                  Expanded(
                    child: Column(
                      children: List.generate(
                        questions[currentQuestion]['options'].length,
                        (index) {
                          final option =
                              questions[currentQuestion]['options'][index];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: VideoOptionCard(
                                key: ValueKey(
                                  option['video'],
                                ), // ðŸ‘ˆ VERY IMPORTANT
                                videoAsset: option['video'],
                                text: option['text'],
                                onTap: () => checkAnswer(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoOptionCard extends StatefulWidget {
  final String videoAsset;
  final String text;
  final VoidCallback onTap;

  const VideoOptionCard({
    super.key,
    required this.videoAsset,
    required this.text,
    required this.onTap,
  });

  @override
  State<VideoOptionCard> createState() => _VideoOptionCardState();
}

class _VideoOptionCardState extends State<VideoOptionCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setLooping(true);
          _controller.setVolume(0);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: _controller.value.isInitialized
                        ? _controller.value.aspectRatio
                        : 1,
                    child: IgnorePointer(
                      child: _controller.value.isInitialized
                          ? VideoPlayer(_controller)
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






