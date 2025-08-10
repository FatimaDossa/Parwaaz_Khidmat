
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_stats_service.dart';
import '../utils/helper_functions.dart';



final Map<String, Color> emotionColors = {
  'Angry': Colors.red,
  'Happy': Colors.yellow[700]!,
  'Sad': Colors.blue,
  'Afraid': Colors.purple,
  'Surprised': Colors.orange,
  'Worried': Colors.teal,
};

class EmotionLabel extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool showWhiteBackground;

  const EmotionLabel(
    this.label, {
    this.fontSize = 18,
    this.showWhiteBackground = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showWhiteBackground ? Colors.white : Colors.transparent,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: emotionColors[label] ?? Colors.black,
        ),
      ),
    );
  }
}



// class flutterTtsUrdu {
//   static final FlutterTts _tts = FlutterTts();

//   static Future<void> init() async {
//     await _tts.setLanguage("ur-PK");
//     await _tts.setPitch(1.0);
//     await _tts.setSpeechRate(0.2);
//     await _tts.awaitSpeakCompletion(true);
//   }

//   static Future<void> speak(String message) async {
//     await _tts.speak(message);
//   }

//   static Future<void> stop() async {
//     await _tts.stop();
//   }
// }


class flutterTtsEng {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> init() async {
    await _tts.setLanguage("en-US");

    // Try faster speech rate
    await _tts.setSpeechRate(0.3); // Increase this if still too slow

    await _tts.setPitch(1.0); // Slightly higher pitch for child-friendly tone
    await _tts.setVolume(1.0); // Max volume
  }

  static Future<void> speak(String message) async {
    await _tts.speak(message);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
  
}

class GameStartScreenS extends StatefulWidget {
  const GameStartScreenS({super.key});

  @override
  State<GameStartScreenS> createState() => _GameStartScreenSState();
}

class _GameStartScreenSState extends State<GameStartScreenS> {
  @override
  void initState() {
    super.initState();

    flutterTtsEng.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // flutterTtsUrdu.speak("سلام! آئیں کھیل شروع کریں۔ جب آپ تیار ہوں تو اسٹارٹ کا بٹن دبائیں۔");
      flutterTtsEng.speak("To revise the emotions. Press Revise Emotions. To begin the game. Press the Start Game button.");
    });
  }

  @override
  void dispose() {
    // flutterTtsUrdu.stop();
    flutterTtsEng.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('Emotion Game'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {await navigateToUserDashboard(context);},
      ),
    ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/final_bg.png', fit: BoxFit.cover),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Revise Button
                  SizedBox(
                    width: double.infinity,
                    height: 100.h,
                    child: ElevatedButton(
                      onPressed: () {
                        flutterTtsEng.stop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmotionRevisionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Revise Emotions",
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Start Game Button
                  SizedBox(
                    width: double.infinity,
                    height: 100.h,
                    child: ElevatedButton(
                      onPressed: () {
                        flutterTtsEng.stop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const TransitionToLevel1()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Start Game",
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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
}

class EmotionRevisionScreen extends StatefulWidget {
  const EmotionRevisionScreen({Key? key}) : super(key: key);

  @override
  State<EmotionRevisionScreen> createState() => _EmotionRevisionScreenState();
}

class _EmotionRevisionScreenState extends State<EmotionRevisionScreen> {
  final List<Map<String, String>> _emotions = [
    {"label": "Happy", "image": "assets/images/happy.png"},
    {"label": "Sad", "image": "assets/images/sad.png"},
    {"label": "Angry", "image": "assets/images/angry.png"},
    {"label": "Afraid", "image": "assets/images/afraid.png"},
    {"label": "Surprised", "image": "assets/images/surprised.png"},
    {"label": "Worried", "image": "assets/images/worried.png"},
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    flutterTtsEng.init();
    _speakCurrentEmotion();
  }

  void _speakCurrentEmotion() async {
    await flutterTtsEng.speak(_emotions[_currentIndex]["label"]!);
  }

  void _nextEmotion() async {
    if (_currentIndex < _emotions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _speakCurrentEmotion();
    } else {
      _showEndDialog();
    }
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Revision Complete"),
        content: const Text("Do you want to revise again or start the game?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
              _speakCurrentEmotion();
            },
            child: const Text("Revise Again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TransitionToLevel1()),
              );
            },
            child: const Text("Start Game"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTtsEng.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emotion = _emotions[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/final_bg.png', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  emotion["image"]!,
                  width: 250.w,
                  height: 250.h,
                ),
                const SizedBox(height: 30),
                EmotionLabel(emotion["label"]!, fontSize: 45.sp),
                // Text(
                //   emotion["label"]!,
                //   style: TextStyle(
                //     fontSize: 45.sp,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _nextEmotion,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 32.sp),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.h,
            left: 16.w,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white, size: 28.sp),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Quit Revision"),
                        content: const Text("Are you sure you want to quit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {await navigateToUserDashboard(context);},
                            child: const Text("Quit"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),

        ],
      ),
    );
  }

}


class TransitionToLevel1 extends StatefulWidget {
  const TransitionToLevel1({super.key});

  @override
  State<TransitionToLevel1> createState() =>
      _TransitionToLevel1State();
}

class _TransitionToLevel1State extends State<TransitionToLevel1>
    with TickerProviderStateMixin {
  List<Offset> scaledFootprints = [];
  int currentPrint = -1;
  bool showStartDot = false;
  bool showEndDot = false;

  late AnimationController _dotController;
  late Animation<double> _dotScaleAnimation;
  List<AnimationController> footprintControllers = [];
  List<Animation<double>> footprintScales = [];
  List<Animation<double>> footprintOpacities = [];


  @override
  void initState() {
    super.initState();
    // flutterTtsUrdu.init();

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _dotScaleAnimation = CurvedAnimation(
      parent: _dotController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      scaledFootprints = generateResponsivePoints(size);

      // Setup one controller per footprint
      for (int i = 0; i < scaledFootprints.length; i++) {
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        footprintControllers.add(controller);
        footprintScales.add(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        );
        footprintOpacities.add(
          Tween<double>(begin: 0, end: 1).animate(controller),
        );
      }

      // Show start dot
      setState(() {
        showStartDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before first footprint
      await Future.delayed(const Duration(milliseconds: 800));

      // Start animating footprints one by one
      for (int i = 0; i < scaledFootprints.length; i++) {
        setState(() {
          currentPrint = i;
        });
        footprintControllers[i].forward(); // Trigger animation
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Delay before showing end dot
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        showEndDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before popup
      await Future.delayed(const Duration(seconds: 2));
      _showGamePopup();
    });
  }


  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _showGamePopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Emotion Recognition Game"),
        content: const Text(
          "You are now going to start the first level in which you have to match the emotions with the correct name. Best of luck!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CardGame()), // Replace with your game 
              );
            },
            child: const Text("Start Game"),
          )
        ],
      ),
    );
    // flutterTtsUrdu.init();
    // flutterTtsUrdu.speak(
    //   "اب آپ پہلا مرحلہ شروع کرنے جا رہے ہیں، جس میں آپ نے جذبات کو صحیح نام سے ملانا ہے۔ آپ کو بہت سی دعائیں!",
    // );
  }


  List<Offset> generateResponsivePoints(Size size) {
    final w = size.width;
    final h = size.height;

    return [
      // Offset(w * 0.42, h * 0.85),
      Offset(w * 0.32, h * 0.75),
      Offset(w * 0.24, h * 0.68),
      // Offset(w * 0.18, h * 0.7),
      // Offset(w * 0.1, h * 0.5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final Offset endDot = Offset(size.width * 0.04, size.height * 0.54);
    final Offset startDot = Offset(size.width * 0.40, size.height * 0.74);

    return Scaffold(
      appBar: AppBar(title: const Text("Level Up")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/map_final.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Start dot
          if (showStartDot)
            Positioned(
              left: startDot.dx,
              top: startDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset('assets/images/home_stop.png', 
                  width: 90,height: 90,),
              ),
            ),

          // Footprints
          for (int i = 0; i <= currentPrint && i < scaledFootprints.length; i++)
            Positioned(
              left: scaledFootprints[i].dx,
              top: scaledFootprints[i].dy,
              child: AnimatedBuilder(
                animation: footprintControllers[i],
                builder: (context, child) => Opacity(
                  opacity: footprintOpacities[i].value,
                  child: Transform.scale(
                    scale: footprintScales[i].value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/images/paw_left.png',
                  height: 45,
                  width: 45,
                ),
              ),
            ),
          // End dot
          if (showEndDot)
            Positioned(
              left: endDot.dx,
              top: endDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset('assets/images/level_1.png', 
                  width:120, height:120,),
              ),
            ),
        ],
      ),
    );
  }
}


class CardGame extends StatefulWidget {
  const CardGame({super.key});

  @override
  State<CardGame> createState() => _CardGameState();
}

class CardLevel {
  final String imagePath;
  final String correctAnswer;

  CardLevel({required this.imagePath, required this.correctAnswer});
}

class _CardGameState extends State<CardGame> {
  final List<CardLevel> levels = [
    CardLevel(imagePath: "assets/images/afraid.png", correctAnswer: "Afraid"),
    CardLevel(imagePath: "assets/images/angry.png", correctAnswer: "Angry"),
    CardLevel(imagePath: "assets/images/happy.png", correctAnswer: "Happy"),
    CardLevel(imagePath: "assets/images/sad.png", correctAnswer: "Sad"),
    CardLevel(imagePath: "assets/images/surprised.png", correctAnswer: "Surprised"),
    CardLevel(imagePath: "assets/images/worried.png", correctAnswer: "Worried")
  ];

  // final Map<String, String> urduMap = {
  //   'Afraid': 'ڈرا ہوا',
  //   'Angry': 'غصہ',
  //   'Happy': 'خوش',
  //   'Sad': 'اداس',
  //   'Surprised': 'حیران',
  //   'Worried': 'فکر مند',
  // };


  //state variables
  int currentLevel = 0;
  bool showFeedback = false;
  String feedbackMessage = "";

  late Stopwatch stopwatch;
  Timer? timer;
  int totalScore = 0;
  int timesPlayed = 0;
  int attempts = 0;

  final List<String> allAnswers = ['Afraid', 'Angry', 'Happy', 'Sad', 'Surprised', 'Worried'];
  List<String> currentOptions = [];
  int currentlySpeakingIndex = -1; // used to highlight the option being spoken

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();     // Start the timer
    totalScore = 0;                       // Initialize score
    attempts = 0;                         // Initialize attempt count
    generateOptionsForLevel();           // Generate initial options
    flutterTtsEng.init();

      // Update timer every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {}); // refresh UI to update time
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void generateOptionsForLevel() {
    final level = levels[currentLevel];
    List<String> options = [level.correctAnswer];
    List<String> incorrect = allAnswers.where((a) => a != level.correctAnswer).toList()..shuffle();
    options.addAll(incorrect.take(2));
    options.shuffle();

    setState(() {
      currentOptions = options;
    });
  }

  void speakOptionsSequentially(List<String> options) async {
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      setState(() {
        currentlySpeakingIndex = i;
      });

      // await flutterTtsUrdu.speak(urduMap[option] ?? option);
      await flutterTtsEng.speak(option);
      await Future.delayed(const Duration(seconds: 2)); // wait before next
    }

    setState(() {
      currentlySpeakingIndex = -1;
    });
  }

  void showTemporaryMessage(String message,Color color, {
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onComplete,}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 42),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (mounted) {
        overlayEntry.remove();
        if (onComplete != null) onComplete(); // trigger callback after removal
      }
    });
  }

  void showConfetti(){
    Lottie.asset("assets/animations/Confetti.json", repeat: false);
  }

  void checkAnswer(String selected) async {
    attempts++;
    final level = levels[currentLevel];

    if (selected == level.correctAnswer) {
      // Scoring
      int points = attempts == 1 ? 30 : (attempts == 2 ? 20 : 10);
      totalScore += points;
      attempts = 0;

      // ✅ Show "Correct!" message before speaking
      setState(() {
        showFeedback = true;
        feedbackMessage = "Correct!";
      });

      // 🎙️ Speak positive message
      showTemporaryMessage("Correct!", Colors.green);
      showConfetti();
      // await flutterTtsUrdu.speak("شاباش! بہت خوب");
      await flutterTtsEng.stop();
      await flutterTtsEng.speak("Good Job");

      // ✅ Message stays on screen while TTS is speaking
      await Future.delayed(const Duration(seconds: 2)); // Small pause after speech

      if (currentLevel < levels.length - 1) {
        // ✅ Move to next level
        setState(() {
          currentLevel++;
          showFeedback = false;
          feedbackMessage = "";
        });

        generateOptionsForLevel(); // generate new options
      } else {
        // 🎙️ Speak final congratulation before replay prompt      

        stopwatch.stop(); // ⏱️ Stop the timer

        final userId = FirebaseAuth.instance.currentUser!.uid;
        final score = totalScore.toDouble();
        final timeSpent = stopwatch.elapsed.inSeconds.toDouble();

        // ✅ Save stats to Firestore
        await GameStatsService().updateGamePartStats(
          gameId: 'Emotion Explorer',
          userId: userId,
          partId: 'part1',
          score: score,
          timeSpent: timeSpent,
        );

        // ✅ Now show replay/next stage dialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Level Completed!"),
            content: const Text("Do you want to exit or go to the next stage?"),
            actions: [
              TextButton(
                onPressed: () async {await navigateToUserDashboard(context);
                  // setState(() {
                  //   timesPlayed++; 
                  //   // currentLevel = 0;
                  //   // generateOptionsForLevel();
                  // });
                },
                child: const Text("Exit Game"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransitionToLevel2(),
                    ),
                  );
                },
                child: const Text("Next Stage"),
              ),
            ],
          ),
        );
        // await flutterTtsUrdu.speak("آپ نے تمام سوالات مکمل کر لیے ہیں");
      }

    } else {
      // ❌ Wrong answer
      setState(() {
        showFeedback = true;
        feedbackMessage = "Try again!";
      });

      // 🎙️ Speak failure message
      showTemporaryMessage("Try again!", Colors.red);
      // await flutterTtsUrdu.stop();
      // await flutterTtsUrdu.speak("کوئی بات نہیں، دوبارہ کوشش کرو");
      await flutterTtsEng.stop();
      await flutterTtsEng.speak("Try Again");
      

      // ✅ Message stays on screen until TTS finishes
      setState(() {
        showFeedback = false;
        feedbackMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = levels[currentLevel];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Emotion Recognition"),
      automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 🟣 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/final_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🟢 Main Game Content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $totalScore',
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Time: ${stopwatch.elapsed.inSeconds}s',
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Emotion Image
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Image.asset(
                      level.imagePath,
                      key: ValueKey(level.imagePath),
                      height: screenHeight * 0.35,
                      width: screenWidth * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Speaker Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            size: screenWidth * 0.12, color: Colors.white),
                        onPressed: () {
                          speakOptionsSequentially(currentOptions);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),


                  // Option Buttons
                  ...currentOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSpeaking = index == currentlySpeakingIndex;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSpeaking
                                ? const Color.fromARGB(255, 0, 81, 255)
                                : Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.01,
                              horizontal: screenWidth * 0.02,
                            ),
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // child: Text(
                          //   option,
                          //   style: const TextStyle(color: Colors.black),
                          // ),
                          child: EmotionLabel(option, fontSize: 28, showWhiteBackground: true,),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: screenHeight * 0.06),
                ],
              ),
            ),
          ),
          // 🔁 Skip Level Button
                  Positioned(
                    right: screenWidth * 0.01,
                    bottom: screenHeight * 0.01,
                    // child: Padding(
                    // padding: EdgeInsets.only(top: 26.h),

                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (currentLevel < levels.length - 1) {
                          setState(() {
                            currentLevel++;
                            attempts = 0;
                            showFeedback = false;
                            feedbackMessage = "";
                          });
                          generateOptionsForLevel();
                        } else {
                          Future.delayed(const Duration(milliseconds: 300), () async {
                          // Final level skipped — show completion dialog
                          stopwatch.stop(); // ⏱️ Stop the timer

                          final userId = FirebaseAuth.instance.currentUser!.uid;
                          final score = totalScore.toDouble();
                          final timeSpent = stopwatch.elapsed.inSeconds.toDouble();

                          // ✅ Save stats to Firestore
                          await GameStatsService().updateGamePartStats(
                            gameId: 'Emotion Explorer',
                            userId: userId,
                            partId: 'part1',
                            score: score,
                            timeSpent: timeSpent,
                          );

                          // ✅ Now show replay/next stage dialog
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Level Completed!"),
                              content: const Text("Do you want to exit or go to the next stage?"),
                              actions: [
                                TextButton(
                                  onPressed: () async {await navigateToUserDashboard(context);
                                    // setState(() {
                                    //   currentLevel = 0;
                                    //   generateOptionsForLevel();
                                    // });
                                  },
                                  child: const Text("Exit Game"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TransitionToLevel2(),
                                      ),
                                    );
                                  },
                                  child: const Text("Next Stage"),
                                ),
                              ],
                            ),
                          );
                          });
                          }
                      },
                      icon: const Icon(Icons.skip_next),
                      label: const Text("Skip"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      ),
                    ),
                    // )
                  ),
                  SizedBox(height: screenHeight * 0.03),

          // 🔴 Game Control Buttons (bottom-left)
          Positioned(
            left: screenWidth * 0.01,
            bottom: screenHeight * 0.01,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white, size: 28.sp),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Quit Game"),
                        content: const Text("Are you sure you want to quit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                            child: const Text("Quit"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.04),

                // Pause Button
                IconButton(
                  icon: Icon(Icons.pause_circle_filled,
                      color: Colors.white, size: screenWidth * 0.09),
                  tooltip: "Pause Game",
                  onPressed: () {
                    setState(() {
                      stopwatch.stop();
                      // Optionally show a pause overlay
                    });
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Game Paused"),
                        content: const Text("Press Resume to continue."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              stopwatch.start();
                            },
                            child: const Text("Resume"),
                          )
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(width: screenWidth * 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransitionToLevel2 extends StatefulWidget {
  const TransitionToLevel2({super.key});

  @override
  State<TransitionToLevel2> createState() =>
      _TransitionToLevel2State();
}

class _TransitionToLevel2State extends State<TransitionToLevel2>
    with TickerProviderStateMixin {
  List<Offset> scaledFootprints = [];
  int currentPrint = -1;
  bool showStartDot = false;
  bool showEndDot = false;

  late AnimationController _dotController;
  late Animation<double> _dotScaleAnimation;
  List<AnimationController> footprintControllers = [];
  List<Animation<double>> footprintScales = [];
  List<Animation<double>> footprintOpacities = [];


  @override
  void initState() {
    super.initState();
    // flutterTtsUrdu.init();

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _dotScaleAnimation = CurvedAnimation(
      parent: _dotController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      scaledFootprints = generateResponsivePoints(size);

      // Setup one controller per footprint
      for (int i = 0; i < scaledFootprints.length; i++) {
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        footprintControllers.add(controller);
        footprintScales.add(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        );
        footprintOpacities.add(
          Tween<double>(begin: 0, end: 1).animate(controller),
        );
      }

      // Show start dot
      setState(() {
        showStartDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before first footprint
      await Future.delayed(const Duration(milliseconds: 800));

      // Start animating footprints one by one
      for (int i = 0; i < scaledFootprints.length; i++) {
        setState(() {
          currentPrint = i;
        });
        footprintControllers[i].forward(); // Trigger animation
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Delay before showing end dot
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        showEndDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before popup
      await Future.delayed(const Duration(seconds: 2));
      _showGamePopup();
    });
  }


  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _showGamePopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Emotions Memory Game"),
        content: const Text(
          "You are now going to start the second level in which you have to find pairs of the same emotion. Best of luck!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen()), // Replace with your game 
              );
            },
            child: const Text("Start Game"),
          )
        ],
      ),
    );
    // flutterTtsUrdu.speak("اب آپ دوسرا مرحلہ کھیلنے جا رہے ہیں، جس میں آپ کو چہرے اور جذبات کو یاد رکھ کر اُن کا جوڑا بنانا ہے۔ دھیان سے دیکھیں، یاد رکھیں، اور ملائیں۔ آپ یہ کر سکتے ہیں! بہت سی دعائیں!");
  }


  List<Offset> generateResponsivePoints(Size size) {
    final w = size.width;
    final h = size.height;

    return [
      // Offset(w * 0.17, h * 0.62),
      Offset(w * 0.24, h * 0.55),
      Offset(w * 0.305, h * 0.48),
      // Offset(w * 0.18, h * 0.7),
      // Offset(w * 0.1, h * 0.5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final Offset startDot = Offset(size.width * 0.07, size.height * 0.56);
    final Offset endDot = Offset(size.width * 0.31, size.height * 0.35);

    // Dynamically scale based on screen size
    final double dotSize = size.width * 0.25;      // ~25% of screen width
    final double footprintSize = size.width * 0.10; // ~12% of screen width

    return Scaffold(
      appBar: AppBar(title: const Text("Level Up")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/map_final.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Start dot
          if (showStartDot)
            Positioned(
              left: startDot.dx,
              top: startDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset(
                  'assets/images/level_1.png',
                  width: dotSize,
                  height: dotSize,
                ),
              ),
            ),

          // Footprints
          for (int i = 0; i <= currentPrint && i < scaledFootprints.length; i++)
            Positioned(
              left: scaledFootprints[i].dx,
              top: scaledFootprints[i].dy,
              child: AnimatedBuilder(
                animation: footprintControllers[i],
                builder: (context, child) => Opacity(
                  opacity: footprintOpacities[i].value,
                  child: Transform.scale(
                    scale: footprintScales[i].value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/images/paw_right.png',
                  width: footprintSize,
                  height: footprintSize,
                ),
              ),
            ),

          // End dot
          if (showEndDot)
            Positioned(
              left: endDot.dx,
              top: endDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset(
                  'assets/images/level_2.png',
                  width: dotSize,
                  height: dotSize,
                ),
              ),
            ),
        ],
      ),
    );
  }
}



class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with SingleTickerProviderStateMixin {
  late List<String> _emotions;
  late List<bool> _flipped;
  late List<bool> _matched;
  late AnimationController _matchAnimationController;
  late Animation<double> _matchAnimation;
  Set<int> _matchedIndices = {};
  int _firstFlippedIndex = -1;
  int _level = 1;
  int _gridRows = 2;
  int _gridCols = 2;
  bool _busy = false;
  int _score = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  bool showLevelCompleteOverlay = false;

  final Map<String, String> _emotionAssets = {
    "Happy": "assets/images/happy.png",
    "Sad": "assets/images/sad.png",
    "Angry": "assets/images/angry.png",
    "Afraid": "assets/images/afraid.png",
    "Surprised": "assets/images/surprised.png",
    "Worried": "assets/images/worried.png",
  };

  @override
  void initState() {
    super.initState();
    _score = 0;
    stopwatch.start();
    _setupGame();

    _matchAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    );

    _matchAnimation = Tween<double>(begin: 1.0, end: 1.15)
      .animate(CurvedAnimation(parent: _matchAnimationController, curve: Curves.easeInOut))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _matchAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Remove bouncing cards once animation is done
        setState(() {
          _matchedIndices.clear();
        });
      }
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {}); // refresh UI to update time
      }
    });
  }

  void _setupGame() {
    final emotions = _emotionAssets.keys.toList()..shuffle();
    final count = (_gridRows * _gridCols) ~/ 2;
    _emotions = (emotions.take(count).toList() + emotions.take(count).toList())..shuffle();
    _flipped = List.filled(_emotions.length, false);
    _matched = List.filled(_emotions.length, false);
    _firstFlippedIndex = -1;
    _busy = false;
  }

  void _flipCard(int index) async {
    if (_busy || _flipped[index] || _matched[index]) return;

    setState(() => _flipped[index] = true);

    if (_firstFlippedIndex == -1) {
      _firstFlippedIndex = index;
    } else {
      final secondIndex = index;
      _busy = true;
      await Future.delayed(const Duration(seconds: 1));

      if (_emotions[_firstFlippedIndex] == _emotions[secondIndex]) {
          setState(() {
            _matched[_firstFlippedIndex] = true;
            _matched[secondIndex] = true;
            _matchedIndices.add(_firstFlippedIndex);
            _matchedIndices.add(secondIndex);
            _score += 10;
            _matchAnimationController.forward(from: 0); // triggers one bounce
          });
        } else {
        setState(() {
          _flipped[_firstFlippedIndex] = false;
          _flipped[secondIndex] = false;
          _score -= 2;
        });
      }
      _firstFlippedIndex = -1;
      _busy = false;

      if (_matched.every((m) => m)) {
        await Future.delayed(const Duration(milliseconds: 600));
        _showLevelComplete();
      }
    }
  }

  void showTemporaryMessage(
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
    }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 42),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (mounted) {
        overlayEntry.remove();
        if (onComplete != null) onComplete(); // trigger callback after removal
      }
    });
  }

  void _showLevelComplete() async {
    stopwatch.stop();

    setState(() {
      showLevelCompleteOverlay = true;
    });
    showTemporaryMessage("Great Job!", Colors.green);
    // await flutterTtsUrdu.stop();
    // await flutterTtsUrdu.speak("شاباش! بہت خوب");
    await flutterTtsEng.stop();
    await flutterTtsEng.speak("Good Job!");

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      showLevelCompleteOverlay = false;
    });
    _nextLevel(); // Call your existing function to go to next level
  }

  void _nextLevel() async {
    setState(() async {
      _level++;
      if (_level >= 4 && _level < 7 ) {
        _gridRows = 2;
        _gridCols = 3;
      } else if (_level >= 7 && _level < 9) {
        _gridRows = 3;
        _gridCols = 4;
      } else if (_level > 9){

        stopwatch.stop(); // ⏱️ Stop the timer
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final score = _score.toDouble(); // replace `_score` with your actual variable
        final timeSpent = stopwatch.elapsed.inSeconds.toDouble();

        await GameStatsService().updateGamePartStats(
          gameId: 'Emotion Explorer',
          userId: userId,
          partId: 'part2',
          score: score,
          timeSpent: timeSpent,
        );

        if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Level Completed!"),
              content: const Text("Do you want to exit or go to the next stage?"),
              actions: [
                TextButton(
                  onPressed: () async {await navigateToUserDashboard(context);
                  //   setState(() {
                  //     _level = 1;});
                  },
                  child: const Text("Exit Game"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransitionToLevel3(),
                      ),
                    );
                  },
                  child: const Text("Next Stage"),
                ),
              ],
            ),
          );
        // await flutterTtsUrdu.stop();
        // await flutterTtsUrdu.speak("آپ نے تمام سوالات مکمل کر لیے ہیں");
      }
        
      // stopwatch.reset();
      stopwatch.start();
      _setupGame();

    });
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    _matchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardSize = screenSize.width / _gridCols - 16.w;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memory Game - Level $_level',
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/final_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $_score', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white,),
                    ),
                    Text(
                      'Time: ${stopwatch.elapsed.inSeconds}s', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white,),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child : GridView.builder(
                    shrinkWrap: true,
                    itemCount: _emotions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCols,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                    ),
                    itemBuilder: (context, index) {
                      final flipped = _flipped[index] || _matched[index];
                      

                      return GestureDetector(
                        onTap: () => _flipCard(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: _matched[index] ? Colors.green.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.r,
                              ),
                            ],
                          ),
                          child: Center(
                            child: flipped
                              ? AspectRatio(
                                  aspectRatio: 3 / 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: _matchedIndices.contains(index)
                                            ? ScaleTransition(
                                                scale: _matchAnimation,
                                                child: Image.asset(
                                                  _emotionAssets[_emotions[index]]!,
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            : Image.asset(
                                                _emotionAssets[_emotions[index]]!,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Expanded(
                                        flex: 1,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: EmotionLabel(_emotions[index], fontSize: 16.sp),
                                          // child: Text(
                                          //   _emotions[index],
                                          //   style: TextStyle(
                                          //     fontSize: 16.sp,
                                          //     fontWeight: FontWeight.bold,
                                          //     color: Colors.black87,
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : Icon(Icons.lock_outline, size: 32.sp),

                          ),  
                        ),
                      );
                    },
                  ),
                ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: ElevatedButton.icon(
                      onPressed: _nextLevel,
                      icon: const Icon(Icons.skip_next),
                      label: const Text("Skip"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 16.w,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white, size: 28.sp),
                  onPressed: () {
                    stopwatch.stop();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Quit Game"),
                        content: const Text("Are you sure you want to quit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {await navigateToUserDashboard(context);},
                            child: const Text("Quit"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),
                IconButton(
                  icon: Icon(Icons.pause_circle, color: Colors.white, size: 28.sp),
                  onPressed: () {
                    stopwatch.stop();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Game Paused"),
                        content: const Text("Press Resume to continue."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              stopwatch.start();
                            },
                            child: const Text("Resume"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 12.w),
                
              ],
            ),
          ),

        ],
      ),
    );
  }
}


class TransitionToLevel3 extends StatefulWidget {
  const TransitionToLevel3({super.key});

  @override
  State<TransitionToLevel3> createState() =>
      _TransitionToLevel3State();
}

class _TransitionToLevel3State extends State<TransitionToLevel3>
    with TickerProviderStateMixin {
  List<Offset> scaledFootprints = [];
  int currentPrint = -1;
  bool showStartDot = false;
  bool showEndDot = false;

  late AnimationController _dotController;
  late Animation<double> _dotScaleAnimation;
  List<AnimationController> footprintControllers = [];
  List<Animation<double>> footprintScales = [];
  List<Animation<double>> footprintOpacities = [];


  @override
  void initState() {
    super.initState();
    // flutterTtsUrdu.init();

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _dotScaleAnimation = CurvedAnimation(
      parent: _dotController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      scaledFootprints = generateResponsivePoints(size);

      // Setup one controller per footprint
      for (int i = 0; i < scaledFootprints.length; i++) {
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        footprintControllers.add(controller);
        footprintScales.add(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        );
        footprintOpacities.add(
          Tween<double>(begin: 0, end: 1).animate(controller),
        );
      }

      // Show start dot
      setState(() {
        showStartDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before first footprint
      await Future.delayed(const Duration(milliseconds: 800));

      // Start animating footprints one by one
      for (int i = 0; i < scaledFootprints.length; i++) {
        setState(() {
          currentPrint = i;
        });
        footprintControllers[i].forward(); // Trigger animation
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Delay before showing end dot
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        showEndDot = true;
      });
      _dotController.forward(from: 0);

      // Delay before popup
      await Future.delayed(const Duration(seconds: 2));
      _showGamePopup();
    });
  }


  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _showGamePopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Scenario Box Game"),
        content: const Text(
          "You are now going to start the third level in which you have to guess the correct emotion according to the scenario. Best of luck!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TreasureBoxGameScreen()),
              );
            },
            child: const Text("Start Game"),
          )
        ],
      ),
    );
    // flutterTtsUrdu.speak("اب اگلا مرحلہ ہے: ایک خزانے کے ڈبے کو کھولیں اور درست رویے کا انتخاب کریں۔");
  }


  List<Offset> generateResponsivePoints(Size size) {
    final w = size.width;
    final h = size.height;

    return [
      Offset(w * 0.4, h * 0.32),
      Offset(w * 0.5, h * 0.25),
      Offset(w * 0.6, h * 0.17),
      // Offset(w * 0.7, h * 0.),
      // Offset(w * 0.1, h * 0.5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final Offset startDot = Offset(size.width * 0.31, size.height * 0.35);
    final Offset endDot = Offset(size.width * 0.57, size.height * 0.04);

    // Dynamically scale based on screen size
    final double dotSize = size.width * 0.25;      // ~25% of screen width
    final double footprintSize = size.width * 0.10; // ~12% of screen width

    return Scaffold(
      appBar: AppBar(title: const Text("Level Up")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/map_final.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Start dot
          if (showStartDot)
            Positioned(
              left: startDot.dx,
              top: startDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset(
                  'assets/images/level_2.png',
                  width: dotSize,
                  height: dotSize,
                ),
              ),
            ),

          // Footprints
          for (int i = 0; i <= currentPrint && i < scaledFootprints.length; i++)
            Positioned(
              left: scaledFootprints[i].dx,
              top: scaledFootprints[i].dy,
              child: AnimatedBuilder(
                animation: footprintControllers[i],
                builder: (context, child) => Opacity(
                  opacity: footprintOpacities[i].value,
                  child: Transform.scale(
                    scale: footprintScales[i].value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/images/paw_right.png',
                  width: footprintSize,
                  height: footprintSize,
                ),
              ),
            ),

          // End dot
          if (showEndDot)
            Positioned(
              left: endDot.dx,
              top: endDot.dy,
              child: ScaleTransition(
                scale: _dotScaleAnimation,
                child: Image.asset(
                  'assets/images/level_3.png',
                  width: dotSize,
                  height: dotSize,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class TreasureBoxGameScreen extends StatefulWidget {
  const TreasureBoxGameScreen({super.key});

  @override
  State<TreasureBoxGameScreen> createState() => _TreasureBoxGameScreenState();
} 

class _TreasureBoxGameScreenState extends State<TreasureBoxGameScreen> with TickerProviderStateMixin {
  // final List<Map<String, dynamic>> _scenarios = [
  //   {
  //     "image": "assets/images/fighting.png",
  //     "options": ["Angry/Start hitting", "Afraid/Get help"],
  //     "correct": 1,
  //   },
  //   {
  //     "image": "assets/images/fun_with_friends.png",
  //     "options": ["Surprised/Enjoy and play", "Scared/Start shouting"],
  //     "correct": 0,
  //   },
  //   {
  //     "image": "assets/images/girl_hurt.png",
  //     "options": ["Happy/Start laughing", "Worried/Call for help"],
  //     "correct": 1,
  //   },
  //   {
  //     "image": "assets/images/giving_gift.png",
  //     "options": ["Scared/Start shouting", "Happy/Be thankful"],
  //     "correct": 1,
  //   },
  //   {
  //     "image": "assets/images/bad_marks.png",
  //     "options": ["Sad/Console her", "Happy/Make fun"],
  //     "correct": 0,
  //   },
  //   {
  //     "image": "assets/images/sick.png",
  //     "options": ["Worried/Pray for them", "Angry/Get frustrated"],
  //     "correct": 0,
  //   },
  // ];

  final List<Map<String, dynamic>> _scenarios = [
    {
      "image": "assets/images/fighting.png",
      "options": ["assets/images/angry.png", "assets/images/afraid.png"],
      "emotions": ["Angry", "Afraid"],
      "correct": 1,
    },
    {
      "image": "assets/images/fun_with_friends.png",
      "options": ["assets/images/surprised.png", "assets/images/afraid.png"],
      "emotions": ["Surprised", "Afraid"],
      "correct": 0,
    },
    {
      "image": "assets/images/girl_hurt.png",
      "options": ["assets/images/happy.png", "assets/images/worried.png"],
      "emotions": ["Happy", "Worried"],
      "correct": 1,
    },
    {
      "image": "assets/images/giving_gift.png",
      "options": ["assets/images/afraid.png", "assets/images/happy.png"],
      "emotions": ["Afraid", "Happy"],
      "correct": 1,
    },
    {
      "image": "assets/images/bad_marks.png",
      "options": ["assets/images/sad.png", "assets/images/happy.png"],
      "emotions": ["Sad", "Happy"],
      "correct": 0,
    },
    {
      "image": "assets/images/sick.png",
      "options": ["assets/images/worried.png", "assets/images/angry.png"],
      "emotions": ["Worried", "Angry"],
      "correct": 0,
    },
  ];


  late List<AnimationController> _controllers;
  final List<bool> _opened = List.filled(6, false);
  int? _currentIndex;
  bool _showFlashcard = false;
  bool _answered = false;
  int? _selectedOption;
  int currentlySpeakingIndex = -1;
  int _score = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;

  late AnimationController _flashcardController;
  late Animation<double> _flashcardScale;
  late Animation<Offset> _flashcardSlide;
  late Animation<double> _flashcardFade;

  // final Map<String, String> Maps = {
  //   "Angry/Start hitting": "Angry",
  //   "Afraid/Get help": "Afraid",
  //   "Surprised/Enjoy and play": "Surprised",
  //   "Scared/Start shouting": "Scared",
  //   "Happy/Start laughing": "Happy",
  //   "Worried/Call for help": "Worried",
  //   "Happy/Be thankful" : "Happy",
  //   "Sad/Console her": "Sad",
  //   "Happy/Make fun" : "Happy",
  //   "Worried/Pray for them" : "Worried",
  //   "Angry/Get frustrated" : "Angry"

  // };

  final Map<String, String> Maps = {
    "assets/images/angry.png": "Angry",
    "assets/images/afraid.png": "Afraid",
    "assets/images/surprised.png": "Surprised",
    "assets/images/scared.png": "Scared",
    "assets/images/happy.png": "Happy",
    "assets/images/worried.png": "Worried",
    "assets/images/sad.png": "Sad",
  };


  @override
  void initState() {
    super.initState();
    _score = 0;
    stopwatch.start();
    flutterTtsEng.init();
    _controllers = List.generate(
      6,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _flashcardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flashcardSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _flashcardController,
      curve: Curves.easeOut,
    ));

    _flashcardFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flashcardController,
      curve: Curves.easeIn,
    ));

    _flashcardScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashcardController,
      curve: Curves.easeInOutBack,
    ));

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {}); // refresh UI to update time
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _flashcardController.dispose();
    timer?.cancel();
    stopwatch.stop();
    super.dispose();

  }

  void _openTreasureBox(int index) {
    if (_opened[index]) return;

    setState(() {
      _opened[index] = true;
    });

    _controllers[index]
      ..reset()
      ..forward();

    _controllers[index].addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controllers[index].removeStatusListener((_) {});

        setState(() {
          _currentIndex = index;
          _showFlashcard = true;
          _answered = false;
          _selectedOption = null;
        });

        _flashcardController.forward(from: 0);
      }
    });
  }

  void showConfetti(){
    Lottie.asset("assets/animations/Confetti.json", repeat: false);
  }

  void showTemporaryMessage(
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
    }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 42),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (mounted) {
        overlayEntry.remove();
        if (onComplete != null) onComplete(); // trigger callback after removal
      }
    });
  }

  void _checkAnswer(int selected) async {
    if (_answered || _currentIndex == null) return;

    setState(() {
      _selectedOption = selected;
      _answered = true;
    });
    // ✅ Speak on correct answer
    final correctIndex = _scenarios[_currentIndex!]["correct"];
    if (selected == correctIndex) {
      showTemporaryMessage("Correct!", Colors.green);
      showConfetti();
      // await flutterTtsUrdu.stop();
      // await flutterTtsUrdu.speak("شاباش! آپ نے درست جواب دیا");
      await flutterTtsEng.stop();
      await flutterTtsEng.speak("Good Job");


      _score += 10;
    } else {
      showTemporaryMessage("Try again!", Colors.red);
      // await flutterTtsUrdu.stop();
      // await flutterTtsUrdu.speak("غلط جواب! کوئی بات نہیں");
      await flutterTtsEng.stop();
      await flutterTtsEng.speak("Try Again");
      _score -= 2;
    }

    Future.delayed(const Duration(seconds: 2), () async {
      _flashcardController.reverse().then((_) {
        setState(() {
          _showFlashcard = false;
        });

        if (_opened.every((opened) => opened)) {
          Future.delayed(const Duration(milliseconds: 300), () async {
            stopwatch.stop(); // ⏱️ Stop the timer

            final userId = FirebaseAuth.instance.currentUser!.uid;
            final score = _score.toDouble();
            final timeSpent = stopwatch.elapsed.inSeconds.toDouble();

            // ✅ Save stats to Firestore for Part 3
            await GameStatsService().updateGamePartStats(
              gameId: 'Emotion Explorer',
              userId: userId,
              partId: 'part3',
              score: score,
              timeSpent: timeSpent,
            );

            if (!mounted) return;
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Great Job!"),
                content: const Text("You've answered all scenarios!"),
                actions: [
                  TextButton(
                   onPressed: () async {await navigateToUserDashboard(context);},
                    child: const Text("Finish"),
                  ),
                ],
              ),
            );
            // await flutterTtsUrdu.speak("آپ نے تمام سوالات مکمل کر لیے ہیں");
            await flutterTtsEng.speak("Level Complete");
          });
        }
      });
    });
  }

  void speakOptionsSequentially(List<String> options) async {
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      setState(() {
        currentlySpeakingIndex = i;
      });

      // await flutterTtsUrdu.speak(urduMap[option] ?? option);
      await flutterTtsEng.stop();
      await flutterTtsEng.speak(Maps[option] ?? option);
      await Future.delayed(const Duration(seconds: 2)); // wait before next
    }

    setState(() {
      currentlySpeakingIndex = -1;
    });
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Scenario Box Game", style: TextStyle(fontSize: 24.sp)),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // 🔹 Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/final_bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Score and Timer
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $_score',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Time: ${stopwatch.elapsed.inSeconds}s',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Treasure Boxes Grid
            Padding(
              padding: EdgeInsets.only(
                top: 50.h,
                left: 16.w,
                right: 16.w,
                bottom: 50.h,
              ),
              child: GridView.builder(
                itemCount: _scenarios.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.h,
                  crossAxisSpacing: 20.w,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openTreasureBox(index),
                    child: IgnorePointer(
                      ignoring: _opened[index],
                      child: Lottie.asset(
                        'assets/animations/box_open1.json',
                        controller: _controllers[index],
                        repeat: false,
                        onLoaded: (composition) {
                          _controllers[index].duration = composition.duration;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Flashcard Overlay
            if (_showFlashcard && _currentIndex != null)
              Positioned(
                top: 80.h,
                left: 20.w,
                right: 20.w,
                bottom: 100.h,
                child: FadeTransition(
                  opacity: _flashcardFade,
                  child: SlideTransition(
                    position: _flashcardSlide,
                    child: ScaleTransition(
                      scale: _flashcardScale,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 8),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _scenarios[_currentIndex!]["image"],
                                width: 320.w,
                                height: 250.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 12.h),

                              // 🔊 Speaker Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up,
                                        size: 40.sp, color: Colors.white),
                                    onPressed: () {
                                      speakOptionsSequentially(
                                          _scenarios[_currentIndex!]["options"]);
                                    },
                                  ),
                                ],
                              ),

                              // 🔘 Emoji Options (side by side)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  _scenarios[_currentIndex!]["options"].length,
                                  (i) => GestureDetector(
                                    onTap: () => _checkAnswer(i),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: currentlySpeakingIndex == i
                                            ? const Color.fromARGB(255, 33, 229, 243)
                                            // : _answered
                                            //     ? i == _scenarios[_currentIndex!]["correct"]
                                            //         ? Colors.green
                                            //         : i == _selectedOption
                                            //             ? Colors.red
                                            //             : Colors.grey[200]
                                                : emotionColors[_scenarios[_currentIndex!]["emotions"][i]] ?? Colors.white,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(color: Colors.black26),
                                      ),
                                      padding: EdgeInsets.all(12.w),
                                      width: 120.w,
                                      height: 120.w,
                                      child: Image.asset(
                                        _scenarios[_currentIndex!]["options"][i], // Now holds emoji image path
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 🔘 Skip Button
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: 
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.skip_next),
                                    label: const Text("Skip"),
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      _flashcardController.reverse().then((_) {
                                        setState(() {
                                          _showFlashcard = false;
                                          _answered = true;
                                          _selectedOption = null;
                                          _opened[_currentIndex!] = true; // Mark as skipped
                                        });

                                        // Check for game completion
                                        if (_opened.every((opened) => opened)) {
                                          Future.delayed(const Duration(milliseconds: 300), () async {

                                            stopwatch.stop();

                                            final userId = FirebaseAuth.instance.currentUser!.uid;
                                            final score = _score.toDouble();
                                            final timeSpent = stopwatch.elapsed.inSeconds.toDouble();

                                            await GameStatsService().updateGamePartStats(
                                              gameId: 'Emotion Explorer',
                                              userId: userId,
                                              partId: 'part3',
                                              score: score,
                                              timeSpent: timeSpent,
                                            );

                                            if (!mounted) return;
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Great Job!"),
                                                content: const Text("You've answered all scenarios!"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {await navigateToUserDashboard(context);},
                                                    child: const Text("Finish"),
                                                  ),
                                                ],
                                              ),
                                            );
                                            await flutterTtsEng.speak("Level Complete");
                                          });
                                        }
                                      });
                                    },
                                  ),)
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              

            // 🔹 Quit, Pause, Restart Buttons
            Positioned(
              bottom: 12.h,
              left: 16.w,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.exit_to_app,
                        color: Colors.white, size: 28.sp),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Quit Game"),
                          content: const Text("Are you sure you want to quit?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {await navigateToUserDashboard(context);},
                              child: const Text("Quit"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  IconButton(
                    icon: Icon(Icons.pause_circle,
                        color: Colors.white, size: 28.sp),
                    onPressed: () {
                      stopwatch.stop();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Game Paused"),
                          content: const Text("Press Resume to continue."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                stopwatch.start();
                              },
                              child: const Text("Resume"),
                            ),
                          ],
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
