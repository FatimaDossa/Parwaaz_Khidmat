
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:confetti/confetti.dart';

class GameStartScreenB extends StatefulWidget {
  const GameStartScreenB({super.key});

  @override
  State<GameStartScreenB> createState() => _GameStartScreenBState();
}

class _GameStartScreenBState extends State<GameStartScreenB> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Game')),
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
                  // Start Game Button
                  SizedBox(
                    width: double.infinity,
                    height: 100.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SchoolMapScreen()),
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



class SchoolMapScreen extends StatefulWidget {
  const SchoolMapScreen({Key? key}) : super(key: key);

  @override
  State<SchoolMapScreen> createState() => _SchoolMapScreenState();
}

class _SchoolMapScreenState extends State<SchoolMapScreen> with SingleTickerProviderStateMixin {
  final Map<String, bool> visitedLocations = {
    'Classroom': false,
    'Playground': false
  };

  final Map<String, Offset> locationPositions = {
    'Classroom': Offset(50, 160),
    'Playground': Offset(220, 100)
  };

  final Map<String, String> locationIcons = {
    'Classroom': 'assets/images/classroom.png',
    'Playground': 'assets/images/playground.png'
  };

  double _scale = 1.0;


  @override
  void initState() {
    super.initState();
  }


  bool _allLocationsVisited() {
    return visitedLocations.values.every((visited) => visited);
  }

  void _navigateToScenario(String location) async {
    setState(() {
      _scale = 1.05;
    });

    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _scale = 1.0;
    });

    // Navigate to the correct screen and wait until user returns
    if (location == 'Classroom') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClassroomScenarioScreen()),
      );
    } else if (location == 'Playground') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlaygroundScreen()),
      );
    } 
    else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScenarioScreen(location: location)),
      );
    }

    // After returning, mark the location as visited
    setState(() {
      visitedLocations[location] = true;
    });

    // Check if all locations visited
    if (_allLocationsVisited()) {
      _showCompletionDialog();
    }
  }


  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('All Locations Visited!'),
        content: Text('You completed the game.'),
        actions: [
          TextButton(
            onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GameStartScreenB()), );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int visitedCount = visitedLocations.values.where((v) => v).length;
    int totalCount = visitedLocations.length;
    double completionPercentage = (visitedCount / totalCount) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('School Map')),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/school_bg.jpg', fit: BoxFit.cover),
          ),

          // Progress Dashboard (Timer Removed)
          Positioned(
            top: 10.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Visited: $visitedCount / $totalCount',
                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
                  Text('Completed: ${completionPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: screenWidth * 0.045)),
                ],
              ),
            ),
          ),

          // Tappable Locations
          ...locationPositions.entries.map((entry) {
            String location = entry.key;
            Offset position = entry.value;

            return Positioned(
              left: position.dx.w,
              top: position.dy.h,
              child: GestureDetector(
                onTap: () => _navigateToScenario(location),
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 150),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            locationIcons[location] ?? 'assets/images/red_stop.png',
                            width: screenWidth * 0.22,
                            height: screenWidth * 0.22,
                          ),
                          if (visitedLocations[location] == true)
                            Container(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 40),
                            ),
                        ],
                      ),
                      Text(
                        location,
                        style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}

// Dummy Scenario Screen
class ScenarioScreen extends StatelessWidget {
  final String location;
  const ScenarioScreen({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$location Scenario')),
      body: Center(
        child: Text('Welcome to $location', style: TextStyle(fontSize: 24.sp)),
      ),
    );
  }
}





class ClassroomScenarioScreen extends StatefulWidget {
  const ClassroomScenarioScreen({super.key});

  @override
  State<ClassroomScenarioScreen> createState() => _ClassroomScenarioScreenState();
}

class _ClassroomScenarioScreenState extends State<ClassroomScenarioScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();

  List<Map<String, dynamic>> flashcards = [
    {
      'image': 'assets/images/classroom1.jpg',
      'isGood': false,
      'description': 'The student is eating in class without taking permission.'
    },
    {
      'image': 'assets/images/classroom2.jpg',
      'isGood': false,
      'description': 'The students are playing with the books.'
    },
    {
      'image': 'assets/images/classroom3.jpg',
      'isGood': true,
      'description': 'The students are helping each other out.'
    },
    {
      'image': 'assets/images/classroom4.jpg',
      'isGood': false,
      'description': 'The student is sitting on the table rather than the chair.'
    },
    {
      'image': 'assets/images/classroom5.jpg',
      'isGood': true,
      'description': 'The students are listening to the teacher attentively.'
    },
    {
      'image': 'assets/images/classroom6.jpg',
      'isGood': false,
      'description': 'The student is cheating.'
    },
  ];


  Set<int> sortedCards = {};
  Set<int> flippedCards = {}; // To track flipped state
  int score = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  bool gameCompleted = false;

  @override
  void initState() {
    score = 0;
    stopwatch.start();
    super.initState();
    flutterTts.setSpeechRate(0.4);
    // Update timer every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {}); // refresh UI to update time
      }
    });
  }

  void speak(String message) async {
    await flutterTts.stop();
    await flutterTts.speak(message);
  }

  void checkCompletion() async {
    if (sortedCards.length == flashcards.length) {
      await Future.delayed(const Duration(seconds: 3));
      speak('Great job! You have sorted all behaviors correctly.');
      setState(() => gameCompleted = true);
      stopwatch.stop();
      timer?.cancel();
    }
  }

  void showTemporaryMessage(String message, Color color, {
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
        if (onComplete != null) onComplete();
      }
    });
  }

  void handleDrop(int index, bool targetIsGood) async {
    final correct = flashcards[index]['isGood'] == targetIsGood;

    if (correct) {
      showTemporaryMessage("Correct", Colors.green);
      speak('Correct!');
      setState(() {
        sortedCards.add(index);
        score += 10;
        flippedCards.remove(index);
      });
      checkCompletion();
    } else {
      showTemporaryMessage("Try again!", Colors.red);
      speak('Try Again');
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classroom Behavior Game')),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/class_bg.jpg', fit: BoxFit.cover)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Time: ${stopwatch.elapsed.inSeconds}s', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: DragTarget<int>(
              onAccept: (index) => handleDrop(index, true),
              builder: (context, _, __) => _buildTargetBox('Good Behavior', 'assets/images/carton_box.png'),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: DragTarget<int>(
              onAccept: (index) => handleDrop(index, false),
              builder: (context, _, __) => _buildTargetBox('Bad Behavior', 'assets/images/carton_box.png'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 120), // adjust this value to move further down
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(flashcards.length, (index) {
                  if (sortedCards.contains(index)) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.brown[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(10),
                          // content: Column(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Image.asset(
                          //       flashcards[index]['image'],
                          //       width: 380,
                          //       height: 380,
                          //       fit: BoxFit.contain,
                          //     ),
                          //     const SizedBox(height: 20),
                          //     ElevatedButton(
                          //       onPressed: () => Navigator.of(context).pop(),
                          //       child: const Text('Close'),
                          //     ),
                          //   ],
                          // ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                flashcards[index]['image'],
                                width: 450,
                                height: 380,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                flashcards[index]['description'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),

                        ),
                      );
                      String description = flashcards[index]['description'];
                      speak(description);
                    },
                    child: Draggable<int>(
                      data: index,
                      feedback: _buildFlashcard(index, zoom: true),
                      childWhenDragging: Opacity(opacity: 0.5, child: _buildFlashcard(index)),
                      child: _buildFlashcard(index),
                    ),
                  );
                }),
              ),
            ),
          ),

          if (gameCompleted)
            Center(
              child: AlertDialog(
                title: const Text('Game Complete'),
                content: Text('Your time: ${stopwatch.elapsed.inSeconds} seconds\nYour score: $score'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Map'),
                  ),
                ],
              ),
            ),
            // 🔴 Game Control Buttons (bottom-left)
          Positioned(
            left: 16.h,
            bottom: 16.w,
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
                SizedBox(width: 12.w),

                // Pause Button
                IconButton(
                  icon: Icon(Icons.pause_circle_filled,
                      color: Colors.white, size: 28.sp),
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

                SizedBox(width: 12.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(int index, {bool zoom = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedScale(
        scale: zoom ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 100,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.brown[150],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 38,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTargetBox(String label, String imagePath) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 230,
              height: 220,
              fit: BoxFit.contain,
            ),
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class PlaygroundScenario {
  final String image;
  final String description;
  final List<String> steps;
  final List<String> correctOrder;
  final Offset position;
  final Size size;
  

  PlaygroundScenario({
    required this.image,
    required this.description,
    required this.steps,
    required this.correctOrder,
    required this.position,
    required this.size,
  });
}

class _PlaygroundScreenState extends State<PlaygroundScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();

  int currentScenarioIndex = 0;
  bool showWhatToDo = false;
  bool showFlashcard = false;
  bool showFeedback = false;
  String feedbackMessage = '';
  List<String> userSteps = [];
  Set<String> usedSteps = {};
  int score = 0;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  bool gameCompleted = false;
  List<String> currentSteps = [];

  late AnimationController flashcardController;
  int currentlySpeakingIndex = -1; // used to highlight the option being spoken


  final List<PlaygroundScenario> scenarios = [
    PlaygroundScenario(
      image: 'assets/images/playground1.png',
      description: 'The kid has fallen and is hurt.',
      steps: ['Help her get First Aid', 'Call Teacher', 'Calm the Kid'],
      correctOrder: ['Calm the Kid', 'Call Teacher', 'Help her get First Aid'],
      position: Offset(3, 15),
      size: Size(250,250),
    ),
    PlaygroundScenario(
      image: 'assets/images/playground2.png',
      description: 'A fight is happening on the playground.',
      steps: ['Separate Kids', 'Inform Teacher', 'Resolve the Issue'],
      correctOrder: ['Separate Kids', 'Inform Teacher', 'Resolve the Issue'],
      position: Offset(2, 15),
      size: Size(350, 350),
    ),
    PlaygroundScenario(
      image: 'assets/images/playground3.png',
      description: 'The kid is having stomach ache and feeling nauseous.',
      steps: ['Follow teachers instructions', 'Inform the teacher', 'Ask him to sit down'],
      correctOrder: ['Ask him to sit down', 'Inform the teacher', 'Follow teachers instructions'],
      position: Offset(2, 10),
      size: Size(350, 350),
    ),
    PlaygroundScenario(
      image: 'assets/images/playground4.png',
      description: 'One kid is snatching the other kids toy',
      steps: ['Separate Kids', 'Advice to share and not fight', 'Inform Teacher'],
      correctOrder: ['Separate Kids', 'Inform Teacher', 'Advice to share and not fight'],
      position: Offset(3, 3),
      size: Size(350,350),
    ),
  ];

  @override
  void initState() {
    super.initState();
    score = 0;
    stopwatch.start();
    flutterTts.setSpeechRate(0.4);
    flashcardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.8,
      upperBound: 1.0,
    );
    // Update timer every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {}); // refresh UI to update time
      }
    });
    _playScenarioIntro();
  }

  Future<void> _playScenarioIntro() async {
    final scenario = scenarios[currentScenarioIndex];
    await flutterTts.speak(scenario.description);
    flutterTts.setCompletionHandler(() {
      setState(() {
        showWhatToDo = true; // Show "What to do?" after description
      });
    });
  }


  Future<void> _playStepText(String step) async {
    await flutterTts.stop();
    await flutterTts.speak(step);
  }

  void showTemporaryMessage(String message, Color color, {
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
        if (onComplete != null) onComplete();
      }
    });
  }

  void _handleDrop(int index, String data) async {
    if (userSteps.length <= index && !usedSteps.contains(data)) {
      userSteps.add(data);
      usedSteps.add(data);
      setState(() {});

      if (userSteps.length == scenarios[currentScenarioIndex].correctOrder.length) {
        await Future.delayed(const Duration(milliseconds: 500));
        _checkAnswer();
      }
    }
  }

  void _checkAnswer() async {
    final isCorrect = _listEquals(userSteps, scenarios[currentScenarioIndex].correctOrder);

    if (isCorrect) {
      await flutterTts.speak('Good job! That is the correct order.');

        // setState(() {
        //   feedbackMessage = 'Good job!';
        //   showFeedback = true;
        // });
        
        showTemporaryMessage("Correct!", Colors.green);
        score += 20;

        await Future.delayed(const Duration(seconds: 4));
        setState(() {
          showFeedback = false;
          showFlashcard = false;
          userSteps.clear();       // Clear the answer bubbles
          usedSteps.clear();       // Enable all steps again
          showWhatToDo = false;    // Hide the button for next scenario
        });

        if (currentScenarioIndex < scenarios.length - 1) {
          setState(() {
            currentScenarioIndex++;
          });

          await _playScenarioIntro(); // Play next description
        } else {
          setState(() => gameCompleted = true);
          stopwatch.stop();
          timer?.cancel();
        }
      
    } else {
      await flutterTts.speak('Ohho, this is not the correct order, Try again.');
      // setState(() {
      //   feedbackMessage = 'Try Again!';
      //   showFeedback = true;
      // });
      
      showTemporaryMessage("Try Again!", Colors.red);
      score -= 2;
      await Future.delayed(const Duration(seconds: 4));
        setState(() {
          showFeedback = false;
          userSteps.clear();       // Clear the answer bubbles
          usedSteps.clear();    
        });
    }
  }


  void _resetAttempt() {
    setState(() {
      userSteps.clear();
      usedSteps.clear();
      showFeedback = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Playground Complete!'),
        content: const Text('You have finished all the scenarios. Well done!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Closes the dialog
              Navigator.of(context).pop(); // Closes the PlaygroundScreen and goes back to the map
            },
            child: const Text('Back to Map'),
          ),
        ],
      ),
    );
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void speakOptionsSequentially(List<String> steps) async {
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      setState(() {
        currentlySpeakingIndex = i;
      });

      await flutterTts.speak(step);
      await Future.delayed(const Duration(seconds: 2)); // delay to highlight

      // Optional: You could wait for TTS to finish by using a completion handler
    }

    setState(() {
      currentlySpeakingIndex = -1;
    });
  }


  @override
  void dispose() {
    flashcardController.dispose();
    stopwatch.stop();
    flutterTts.stop();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = scenarios[currentScenarioIndex];
    currentSteps = scenario.steps;
    

    return Scaffold(
      appBar: AppBar(title: const Text('Playground Scenarios')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/playground_bg.jpg', fit: BoxFit.cover),
          ),

          Positioned(
            top: 25.h,
            left: 20.w,
            right: 20.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Time: ${stopwatch.elapsed.inSeconds}s',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            left: scenario.position.dx,
            bottom: scenario.position.dy,
            child: Image.asset(
              scenario.image,
              width: scenario.size.width,
              height: scenario.size.height,
            ),
          ),

          if (showWhatToDo)
            Positioned(
              top: 200.h,
              left: 30.w,
              right: 30.w,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showFlashcard = true;
                  });
                  flashcardController.forward(from: 0.8);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text('What to do?', style: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ),

          if (showFlashcard)
            // // Speaker Icon
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.end,
            //         children: [
            //           IconButton(
            //             icon: Icon(Icons.volume_up,
            //                 size: 14.w, color: Colors.white),
            //             onPressed: () {
            //               speakOptionsSequentially(currentSteps);
            //             },
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 4.h),
            Center(
              child: ScaleTransition(
                scale: flashcardController,
                child: Container(
                  width: 350.w,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Arrange the steps in the correct order:', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.black87, size: 28.sp),
                          tooltip: 'Speak Steps',
                          onPressed: () => speakOptionsSequentially(scenario.steps),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: scenario.steps.map((step) {
                          final isUsed = usedSteps.contains(step);
                          return Draggable<String>(
                            data: step,
                            feedback: Material(child: _buildStepBubble(step)),
                            childWhenDragging: Opacity(opacity: 0.5, child: _buildStepBubble(step)),
                            child: GestureDetector(
                              // onTap: () => _playStepText(step),
                              child: Opacity(
                                opacity: isUsed ? 0.4 : 1.0,
                                child: IgnorePointer(
                                  ignoring: isUsed,
                                  child: _buildStepBubble(step),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20.h),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(scenario.correctOrder.length, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: DragTarget<String>(
                              onAccept: (data) => _handleDrop(index, data),
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  width: 250.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: userSteps.length > index
                                      ? Text(userSteps[index], style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))
                                      : const Text('Drop Here'),
                                );
                              },
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: _resetAttempt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        ),
                        child: Text('Refresh', style: TextStyle(fontSize: 18.sp , color: Colors.black , fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (showFeedback)
            Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(feedbackMessage, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              ),
              
            ),
            if (gameCompleted)
            Center(
              child: AlertDialog(
                title: const Text('PlayGround Complete'),
                content: Text('Your time: ${stopwatch.elapsed.inSeconds} seconds\nYour score: $score'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Map'),
                  ),
                ],
              ),
            ),
            // 🔴 Game Control Buttons (bottom-left)
          Positioned(
            left: 12.h,
            bottom: 12.w,
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
                SizedBox(width: 12.w),

                // Pause Button
                IconButton(
                  icon: Icon(Icons.pause_circle_filled,
                      color: Colors.white, size: 28.sp),
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

                SizedBox(width: 12.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStepBubble(String step) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
  //     decoration: BoxDecoration(
  //       color: Colors.blueAccent,
  //       borderRadius: BorderRadius.circular(25.r),
  //     ),
  //     child: Text(step, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
  //   );
  // }
  Widget _buildStepBubble(String step) {
    final isSpeaking = (currentlySpeakingIndex != -1 &&
        currentSteps[currentlySpeakingIndex] == step);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSpeaking ? Colors.green : Colors.blueAccent,
        borderRadius: BorderRadius.circular(25.r),
        border: isSpeaking ? Border.all(color: Colors.white, width: 3.w) : null,
      ),
      child: Text(
        step,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: isSpeaking ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

}



// class PlaygroundScreen extends StatefulWidget {
//   const PlaygroundScreen({super.key});

//   @override
//   State<PlaygroundScreen> createState() => _PlaygroundScreenState();
// }

// class PlaygroundScenario {
//   final String image;
//   final String description;
//   final List<String> steps;
//   final List<String> correctOrder;

//   PlaygroundScenario({
//     required this.image,
//     required this.description,
//     required this.steps,
//     required this.correctOrder,
//   });
// }

// class _PlaygroundScreenState extends State<PlaygroundScreen> with TickerProviderStateMixin {
//   final FlutterTts flutterTts = FlutterTts();
//   int currentScenarioIndex = 0;
//   bool showWhatToDo = false;
//   bool showFlashcard = false;
//   bool showFeedback = false;
//   String feedbackMessage = '';
//   List<String> userSteps = [];

//   late AnimationController flashcardController;

//   final List<PlaygroundScenario> scenarios = [
//     PlaygroundScenario(
//       image: 'assets/images/playground1.png',
//       description: 'The kid has fallen and is hurt.',
//       steps: ['Bring First Aid', 'Call Teacher', 'Calm the Kid'],
//       correctOrder: ['Calm the Kid', 'Call Teacher', 'Bring First Aid'],
//     ),
//     PlaygroundScenario(
//       image: 'assets/images/playground2.png',
//       description: 'A fight is happening on the playground.',
//       steps: ['Separate Kids', 'Inform Teacher', 'Resolve the issue'],
//       correctOrder: ['Separate Kids', 'Inform Teacher', 'Resolve the issue'],
//     ),
//     PlaygroundScenario(
//       image: 'assets/images/playground3.png',
//       description: 'The girls are fighting over the toys',
//       steps: ['Separate Kids', 'Inform Teacher', 'Advice to share and not fight'],
//       correctOrder: ['Separate Kids', 'Inform Teacher', 'Advice to share and not fight'],
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     flashcardController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//       lowerBound: 0.8,
//       upperBound: 1.0,
//     );
//     _playScenarioIntro();
//   }

//   Future<void> _playScenarioIntro() async {
//     final scenario = scenarios[currentScenarioIndex];
//     await flutterTts.speak(scenario.description);
//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         showWhatToDo = true;
//       });
//     });
//   }

//   Future<void> _playStepText(String step) async {
//     await flutterTts.stop();
//     await flutterTts.speak(step);
//   }

//   void _handleDrop(int index, String data) async {
//     if (userSteps.length <= index) {
//       userSteps.add(data);
//       if (userSteps.length == scenarios[currentScenarioIndex].correctOrder.length) {
//         await Future.delayed(const Duration(milliseconds: 500));
//         _checkAnswer();
//       }
//       setState(() {});
//     }
//   }

//   void _checkAnswer() async {
//     final isCorrect = _listEquals(userSteps, scenarios[currentScenarioIndex].correctOrder);
//     if (isCorrect) {
//       await flutterTts.speak('Good job! That is the correct order.');
//       setState(() {
//         feedbackMessage = 'Good job!';
//         showFeedback = true;
//       });
//       await Future.delayed(const Duration(seconds: 2));
//       if (currentScenarioIndex < scenarios.length - 1) {
//         setState(() {
//           currentScenarioIndex++;
//           userSteps.clear();
//           showWhatToDo = false;
//           showFlashcard = false;
//           showFeedback = false;
//         });
//         await _playScenarioIntro();
//       } else {
//         _showCompletionDialog();
//       }
//     } else {
//       await flutterTts.speak('Try again.');
//       setState(() {
//         feedbackMessage = 'Try Again!';
//         showFeedback = true;
//         userSteps.clear();
//       });
//       await Future.delayed(const Duration(seconds: 2));
//       setState(() => showFeedback = false);
//     }
//   }

//   void _showCompletionDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Playground Complete!'),
//         content: const Text('You have finished all the scenarios. Well done!'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Back to Map'),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _listEquals(List<String> a, List<String> b) {
//     if (a.length != b.length) return false;
//     for (int i = 0; i < a.length; i++) {
//       if (a[i] != b[i]) return false;
//     }
//     return true;
//   }

//   @override
//   void dispose() {
//     flashcardController.dispose();
//     flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scenario = scenarios[currentScenarioIndex];

//     return Scaffold(
//       appBar: AppBar(title: const Text('Playground Scenarios')),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset('assets/images/playground_bg2.jpg', fit: BoxFit.cover),
//           ),

//           Positioned(
//             left: 10.w,
//             bottom: 30.h,
//             child: Image.asset(scenario.image, width: 300.w, height: 300.w),
//           ),

//           if (showWhatToDo)
//             Positioned(
//               bottom: 20.h,
//               left: 30.w,
//               right: 30.w,
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showFlashcard = true;
//                   });
//                   flashcardController.forward(from: 0.8);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                   decoration: BoxDecoration(
//                     color: Colors.orangeAccent,
//                     borderRadius: BorderRadius.circular(15.r),
//                   ),
//                   child: Center(
//                     child: Text('What to do?', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white)),
//                   ),
//                 ),
//               ),
//             ),

//           if (showFlashcard)
//             Center(
//               child: ScaleTransition(
//                 scale: flashcardController,
//                 child: Container(
//                   width: 350.w,
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16.r),
//                     boxShadow: [
//                       BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Arrange the steps in the correct order:', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 20.h),

//                       // Options to drag
//                       Wrap(
//                         spacing: 10.w,
//                         runSpacing: 10.h,
//                         children: scenario.steps.map((step) {
//                           return Draggable<String>(
//                             data: step,
//                             feedback: Material(child: _buildStepBubble(step)),
//                             childWhenDragging: Opacity(opacity: 0.5, child: _buildStepBubble(step)),
//                             child: GestureDetector(
//                               onTap: () => _playStepText(step),
//                               child: _buildStepBubble(step),
//                             ),
//                           );
//                         }).toList(),
//                       ),

//                       SizedBox(height: 20.h),

//                       // Drop Targets (Vertical)
//                       Column(
//                         children: List.generate(scenario.correctOrder.length, (index) {
//                           return Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8.h),
//                             child: DragTarget<String>(
//                               onAccept: (data) => _handleDrop(index, data),
//                               builder: (context, candidateData, rejectedData) {
//                                 return Container(
//                                   width: 250.w,
//                                   height: 50.h,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(25.r),
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: userSteps.length > index
//                                       ? Text(userSteps[index], style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))
//                                       : const Text('Drop Here'),
//                                 );
//                               },
//                             ),
//                           );
//                         }),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           if (showFeedback)
//             Center(
//               child: Container(
//                 padding: EdgeInsets.all(20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: Text(feedbackMessage, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepBubble(String step) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: Colors.blueAccent,
//         borderRadius: BorderRadius.circular(25.r),
//       ),
//       child: Text(step, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
//     );
//   }
// }
