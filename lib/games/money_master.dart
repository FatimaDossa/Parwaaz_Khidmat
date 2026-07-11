// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/game_stats_screen.dart';
import 'package:provider/provider.dart'; // <-- Add this
import '../services/game_stats_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

// class MoneyMasterGame extends StatelessWidget {
//   const MoneyMasterGame({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => BudgetProvider(),
//       child: MaterialApp(
//         title: 'Money Master',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           fontFamily: 'Roboto',
//           primarySwatch: Colors.orange,
//         ),
//         home: const LevelSelection(),
//       ),
//     );
//   }
// }
class MoneyMasterGame extends StatelessWidget {
  const MoneyMasterGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.orange[50],
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Money Master", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            centerTitle: true,
          ),
          body: const LevelSelection(),
        ),
      ),
    );
  }
}

class LevelSelection extends StatelessWidget {
  const LevelSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Money Master")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Image.asset('assets/images/money_butterfly.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'Choose a level',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _levelButton(
              context: context,
              label: 'Level 1: Rupee Rumble 🪙',
              builder: (_) => const Level1Rupee(),
            ),
            _levelButton(
              context: context,
              label: 'Level 2: Bazaar Day 🛍️',
              builder: (_) => const Level2Bazaar(),
            ),
            // _levelButton(
            //   context: context,
            //   label: 'Level 3: Change Champion',
            //   builder: (_) => const MoneyMasterLevelThree(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _levelButton({
    required BuildContext context,
    required String label,
    required WidgetBuilder builder,
  }) {
    return Padding(
      
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: builder));
        },
      // i want cute stylized layout :(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 251, 207, 141),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}


// piggy_bank.dart


class PiggyBank extends StatefulWidget {
  const PiggyBank({super.key});

  @override
  State<PiggyBank> createState() => _PiggyBankState();
}

class _PiggyBankState extends State<PiggyBank>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnim = Tween<double>(begin: 2.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Trigger animation after a short delay when widget builds
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>().budget;

    return Positioned(
      top: 20,
      right: 20,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          children: [
            Image.asset(
              'assets/images/money.png', // Make sure you update this to your new "money box / treasure box" image
              width: 80,
            ),
            Text(
              'Rs. $budget',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// budget_provider.dart

class BudgetProvider extends ChangeNotifier {
  int _budget = 700; // Starting budget (you can update this)

  int get budget => _budget;

  void spend(int amount) {
    _budget -= amount;
    notifyListeners();
  }

  void add(int amount) {
    _budget += amount;
    notifyListeners();
  }

  void reset() {
    _budget = 500;
    notifyListeners();
  }
}
// level1_rupee.dart

class PracticeNotes extends StatefulWidget {
  const PracticeNotes({super.key});

  @override
  State<PracticeNotes> createState() => _PracticeNotesState();
}

class _PracticeNotesState extends State<PracticeNotes> {
  late List<int> noteValues;
  int currentNoteIndex = 0;
  String? feedback;

  @override
  void initState() {
    super.initState();
    // Shuffle notes for random order
    noteValues = [10, 20, 50, 100, 500]..shuffle(Random());
  }

  void checkAnswer(int selectedValue) {
    final isCorrect = selectedValue == noteValues[currentNoteIndex];

    setState(() {
      feedback = isCorrect ? "✅ Correct!" : "❌ Try Again!";
    });

    if (!isCorrect) return;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (currentNoteIndex < noteValues.length - 1) {
        setState(() {
          currentNoteIndex++;
          feedback = null;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Level1Rupee()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentValue = noteValues[currentNoteIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Practice: Recognize Notes")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/$currentValue.jpg', height: 150),
            const SizedBox(height: 20),
            const Text("Which note is this?", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [10, 20, 50, 100, 500].map((option) {
                return ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  child: Text("Rs. $option"),
                );
              }).toList(),
            ),
            if (feedback != null) ...[
              const SizedBox(height: 20),
              Text(feedback!, style: const TextStyle(fontSize: 18)),
            ]
          ],
        ),
      ),
    );
  }
}

class Level1Rupee extends StatefulWidget {
  const Level1Rupee({super.key});

  @override
  State<Level1Rupee> createState() => _Level1RupeeState();
}

class _Level1RupeeState extends State<Level1Rupee> {
  int currentIndex = 0;
  int totalGiven = 0;
  int _score = 0;
  late Stopwatch _stopwatch;
  Timer? _ticker;
  bool _statsSaved = false;

  final List<int> noteValues = [10, 20, 50, 100, 500];

  int get _elapsedSeconds => _stopwatch.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _saveLevel1Stats() async {
    if (_statsSaved) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await GameStatsService().updateGamePartStats(
      gameId: 'Money Master',
      userId: user.uid,
      partId: 'level1',
      score: _score.toDouble(),
      timeSpent: _elapsedSeconds.toDouble(),
    );
    _statsSaved = true;
  }

  Future<void> showLevelCompleteDialog() async {
    _stopwatch.stop();
    await _saveLevel1Stats();
    if (!mounted) return;

    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Good Job!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/images/celebration2.json", height: 120),
            const SizedBox(height: 10),
            const Text("You've completed Level 1!"),
          ],
        ),
        actions: [

  TextButton(
    onPressed: () {
      Navigator.of(dialogContext).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameStatsScreen(gameId: 'Money Master'),
        ),
      );
    },
    child: const Text("Back to Home"),
  ),

  TextButton(
    onPressed: () {
      Navigator.of(dialogContext).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Level2Bazaar(),
        ),
      );
    },
    child: const Text("Go to Level 2"),
  ),
],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = items[currentIndex]; // Make sure prices are exact multiples of available notes

    return Scaffold(
      appBar: AppBar(
        title: const Text("Level 1: Rupee Rumble"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: $_score",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Time: ${_elapsedSeconds}s",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Buy: ${item.name} for Rs. ${item.price}",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Image.asset(item.imagePath, height: 150),
            const SizedBox(height: 30),
            const Text("Drag the notes below to pay exactly:"),
            const SizedBox(height: 10),

            

            const SizedBox(height: 30),

            // Drop zone
            DragTarget<int>(
              onAccept: (noteValue) async {
                if (totalGiven + noteValue > item.price) {
                  setState(() {
                    _score = max(0, _score - 2);
                  });
                  // ❌ Prevent giving more than price
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("That's too much! Pay the exact amount."),
                    ),
                  );
                  return;
                }
                if (totalGiven + noteValue < item.price) {
                  setState(() {
                    _score = max(0, _score - 2);
                  });
                  // ❌ Prevent giving less than price
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("That's too less! Pay the exact amount."),
                    ),
                  );
                  return;
                }

                setState(() {
                  totalGiven += noteValue;
                });

                if (totalGiven == item.price) {
                  // 🎉 Show celebration Lottie
                  await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Well done!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset("assets/images/celebration.json", height: 120),
                          const SizedBox(height: 10),
                          const Text("You paid the exact amount!"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  );

                  if (currentIndex < items.length - 1) {
                    setState(() {
                      _score += 10;
                      currentIndex++;
                      totalGiven = 0;
                    });
                  } else {
                    setState(() {
                      _score += 10;
                    });
                    showLevelCompleteDialog();
                  }
                }
              },
              builder: (context, candidateData, rejectedData) => Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Total Given: Rs. $totalGiven",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            // TextButton(
            //   onPressed: () {
            //     setState(() {
            //       totalGiven = 0;
            //     });
            //   },
            //   child: const Text("Reset Amount"),
            // ),
            // Draggable notes
            Wrap(
              spacing: 12,
              children: noteValues.map((value) {
                return Draggable<int>(
                  data: value,
                  feedback: Image.asset('assets/images/$value.jpg', height: 80),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset('assets/images/$value.jpg', height: 80),
                  ),
                  child: Image.asset('assets/images/$value.jpg', height: 80),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// level2_bazaar.dart

class Level2Bazaar extends StatefulWidget {
  const Level2Bazaar({super.key});

  @override
  State<Level2Bazaar> createState() => _Level2BazaarState();
}

class _Level2BazaarState extends State<Level2Bazaar>
    with TickerProviderStateMixin {
  List<String> shoppingList = ['carrot', 'mango'];
  List<String> purchasedItems = [];
  late FlutterTts tts;
  int _score = 0;
  late Stopwatch _stopwatch;
  Timer? _ticker;
  bool _statsSaved = false;

  final Map<String, int> itemPrices = {
    'mango': 20,
    'carrot': 10,
    'toy': 100,
    'chips': 50,
  };

  int currentStallIndex = 0;
  final stallItems = ["mango", "carrot", "toy", "chips"];

  // Staged animation controllers
  late AnimationController _moneyController;
  late Animation<double> _moneyScale;

  late AnimationController _scrollController;
  late Animation<double> _scrollScale;

  int currentStage = 0; // 0 = money sack, 1 = scroll, 2 = rest of UI

  bool showGoToLevel3Button = false;

  int get _elapsedSeconds => _stopwatch.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    tts = FlutterTts();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    // money sack animation
    _moneyController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _moneyScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _moneyController, curve: Curves.easeInOut),
    );

    // scroll animation
    _scrollController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scrollScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _scrollController, curve: Curves.easeInOut),
    );

    // Start staged reveal
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Stage 0: money sack
    await tts.setLanguage("en-US");
    await tts.speak("This is our money sack.");
    await _moneyController.forward();
    await Future.delayed(const Duration(seconds: 1));

    // Stage 1: shopping list
    setState(() => currentStage = 1);
    await tts.speak("This is our shopping list.");
    await _scrollController.forward();
    await Future.delayed(const Duration(seconds: 1));

    // Stage 2: rest of UI
    setState(() => currentStage = 2);
    await tts.speak("Now let's go shopping.");
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    _moneyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveLevel2Stats() async {
    if (_statsSaved) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await GameStatsService().updateGamePartStats(
      gameId: 'Money Master',
      userId: user.uid,
      partId: 'level2',
      score: _score.toDouble(),
      timeSpent: _elapsedSeconds.toDouble(),
    );
    _statsSaved = true;
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>().budget;

    return Scaffold(
      appBar: AppBar(title: const Text("Level 2: Bazaar Day")),
      body: Stack(
        children: [
          // Stage 0: money sack
          if (currentStage == 0)
            Center(
              child: ScaleTransition(
                scale: _moneyScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/money.png", width: 150, height: 150),
                    const SizedBox(height: 12),
                    const Text("💰 Our Money Sack",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // Stage 1: shopping list
          if (currentStage == 1)
            Center(
              child: ScaleTransition(
                scale: _scrollScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildShoppingList(),
                    const SizedBox(height: 12),
                    const Text("📝 Shopping List",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // Stage 2: full UI
          if (currentStage == 2)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 600),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(alignment: Alignment.topLeft, child: _buildShoppingList()),
                    _buildTopBar(budget),
                    _buildStallsRow(),
                    _buildMoneyRow(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

          if (currentStage == 2) const PiggyBank(),
        ],
      ),

      // floatingActionButton: showGoToLevel3Button
      //     ? FloatingActionButton.extended(
      //         // onPressed: () {
      //         //   Navigator.pushReplacement(
      //         //     context,
      //         //     MaterialPageRoute(builder: (context) =>  Level3Surprise()),
      //         //   );
      //         // },
      //         label: const Text("Go to Level 3"),
      //         icon: const Icon(Icons.arrow_forward),
      //       )
          // : null,
    );
  }

  Widget _buildShoppingList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/scroll.png",
              width: 100, height: 180, fit: BoxFit.contain),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: shoppingList.map((item) {
              final purchased = purchasedItems.contains(item);
              return Opacity(
                opacity: purchased ? 0.4 : 1,
                child: Text(item,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800])),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(int budget) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Remaining Budget: Rs. $budget",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Score: $_score    Time: ${_elapsedSeconds}s",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStallsRow() {
    return SizedBox(
      height: 320,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stallItems.map((item) {
            final price = itemPrices[item]!;
            return Container(
              width: 250,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Image.asset('assets/images/$item.png',
                      height: 180, fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  Text("Price: Rs. $price",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  DragTarget<String>(
                    onAccept: (note) =>
                        _handlePurchase(item, int.parse(note), "Stall"),
                    builder: (context, _, __) => Container(
                      height: 60,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black)),
                      child: const Center(child: Text("Drop Money Here")),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMoneyRow() {
    final notes = [10, 20, 50, 100];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: notes.map((note) {
          return Draggable<String>(
            data: note.toString(),
            feedback: Image.asset('assets/images/$note.jpg', width: 50),
            childWhenDragging:
                Opacity(opacity: 0.3, child: Image.asset('assets/images/$note.jpg', width: 50)),
            child: Image.asset('assets/images/$note.jpg', width: 50),
          );
        }).toList(),
      ),
    );
  }

  void _handlePurchase(String item, int amount, String stallName) async {
    final itemPrice = itemPrices[item] ?? 0;
    final provider = context.read<BudgetProvider>();

    if (amount < itemPrice) {
      setState(() {
        _score = max(0, _score - 2);
      });
      _showReminderDialog("Not enough money. Add more notes.");
      return;
    }

    if (provider.budget < itemPrice) {
      setState(() {
        _score = max(0, _score - 2);
      });
      _showReminderDialog("You don’t have enough budget.");
      return;
    }

    provider.spend(itemPrice);

    if (shoppingList.contains(item) && !purchasedItems.contains(item)) {
      setState(() {
        _score += 10;
        purchasedItems.add(item);
        currentStallIndex++;
      });
      await _showCelebrationDialog("You bought $item!");
    } else if (!shoppingList.contains(item)) {
      setState(() {
        _score = max(0, _score - 1);
      });
      _showReminderDialog("You bought an extra $item!\n Try to buy only what's on the list.");
      // await _showCelebrationDialog("You bought an extra $item!\n Try to buy only what's on the list.");
    }

    if (purchasedItems.length == shoppingList.length) {
      _showLevelCompleteDialog();
    }
  }

  Future<void> _showCelebrationDialog(String message) async {
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Well done!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/images/celebration.json", height: 120),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Continue")),
        ],
      ),
    );
  }

  Future<void> _showLevelCompleteDialog() async {
    _stopwatch.stop();
    await _saveLevel2Stats();
    if (!mounted) return;

    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Great Job!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/images/celebration2.json", height: 120),
            const SizedBox(height: 10),
            const Text("You've completed your shopping list!"),
          ],
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //     setState(() => showGoToLevel3Button = true);
          //   },
          //   child: const Text("Continue Shopping"),
          // ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameStatsScreen(gameId: 'Money Master'),
                ),
              );
            },
            child: const Text("Yay!"),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(String message) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("OK"))
        ],
      ),
    );
  }
}

// level3_surprise.dart

// class Level3Surprise extends StatefulWidget {
//   @override
//   _Level3SurpriseState createState() => _Level3SurpriseState();
// }

// class _Level3SurpriseState extends State<Level3Surprise>

//     with SingleTickerProviderStateMixin {
//       int totalGiven = 0; // Add this to track payment
//   int _score = 0;
//   late Stopwatch _stopwatch;
//   Timer? _ticker;
//   bool _statsSaved = false;

//   List<Map<String, dynamic>> surpriseEvents = [
//     {
//       'message': 'بارش ہو گئی! چھتری خریدنی ہے',
//       'cost': 100,
//       'icon': 'assets/images/umbrella.png',
//       'type': 'rain',
//     },
//     {
//       'message': 'موبائل چارج کروانا ہے',
//       'cost': 150,
//       'icon': 'assets/images/mobile.png',
//       'type': 'mobile',
//     },
//     {
//       'message': 'بجلی کا بل دینا ہے',
//       'cost': 200,
//       'icon': 'assets/images/electricity.png',
//       'type': 'electricity',
//     },
//   ];

//   int currentEventIndex = 0;
//   bool showEvent = false;
//   bool itemPaid = false;
//   Map<String, dynamic>? activeEvent;

//   late AnimationController _controller;
//   late Animation<Offset> _animationOffset;
//   int get _elapsedSeconds => _stopwatch.elapsed.inSeconds;

//   Future<void> _saveLevel3Stats() async {
//     if (_statsSaved) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     await GameStatsService().updateGamePartStats(
//       gameId: 'Money Master',
//       userId: user.uid,
//       partId: 'level3',
//       score: _score.toDouble(),
//       timeSpent: _elapsedSeconds.toDouble(),
//     );
//     _statsSaved = true;
//   }

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );

//     _animationOffset = Tween<Offset>(
//       begin: Offset(0.0, -1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     ));

//     Future.delayed(Duration(milliseconds: 500), _startNextEvent);
//   }

//   void _startNextEvent() {
//     if (currentEventIndex < surpriseEvents.length) {
//       setState(() {
//         activeEvent = surpriseEvents[currentEventIndex];
//         showEvent = true;
//         itemPaid = false;
//       });
//       _controller.forward(from: 0);
//       currentEventIndex++;
//     } else {
//       _showFinalResult();
//     }
//   }

//   Future<void> _showFinalResult() async {
//     _stopwatch.stop();
//     await _saveLevel3Stats();
//     if (!mounted) return;
//     final budget = context.read<BudgetProvider>().budget;
//     showDialog(
//       context: context,
//       useRootNavigator: false,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(
//           budget > 0
//               ? '🎉 آپ نے بجٹ سنبھال لیا!'
//               : '🐷 بجٹ ختم — بچت ضروری ہے!',
//         ),
//         content: budget > 0
//             ? Text('Rs $budget آپ کی بچت ہے')
//             : Text('اگلی بار بہتر منصوبہ بندی کریں'),
//         actions: [
//           TextButton(
//             child: Text('دوبارہ کھیلیں'),
//             onPressed: () {
//               context.read<BudgetProvider>().reset();
//               Navigator.of(dialogContext).pop();
//               setState(() {
//                 _score = 0;
//                 _statsSaved = false;
//                 _stopwatch
//                   ..reset()
//                   ..start();
//                 currentEventIndex = 0;
//                 totalGiven = 0;
//                 showEvent = false;
//                 itemPaid = false;
//               });
//               _startNextEvent();
//             },
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _ticker?.cancel();
//     _stopwatch.stop();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final budget = context.watch<BudgetProvider>().budget;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Surprise Budget Mode'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//             Text(
//               'Rs $budget :موجودہ بچت',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 6),
//             Text(
//               'Score: $_score    Time: ${_elapsedSeconds}s',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//             ),
//             Image.asset(
//               budget > 0
//                   ? 'assets/images/piggy_bank.png'
//                   : 'assets/images/piggy_empty.png',
//               height: 120,
//             ),
//             SizedBox(height: 10),
//             Divider(),
//             Expanded(
//               child: showEvent && activeEvent != null
//                   ? SlideTransition(
//                       position: _animationOffset,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // 🎬 Rain animation
//                           if (activeEvent!['type'] == 'rain') ...[
//                             SizedBox(
//                               height: 150,
//                               child: SizedBox(
//   width: 700,
//   height: 700,
//   child: Lottie.asset('assets/images/raining.json',
//   repeat: true),
// ),
//                             ),
//                             SizedBox(height: 10),
//                           ],
//                           Text(
//                             activeEvent!['message'],
//                             style: TextStyle(fontSize: 20),
//                           ),
//                           SizedBox(height: 10),
//                           DragTarget<String>(
//                             builder: (context, candidateData, rejectedData) {
//                               return Column(
//                                 children: [
//                                   Image.asset(
//                                     activeEvent!['icon'],
//                                     height: 100,
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text('Rs ${activeEvent!['cost']} درکار ہیں'),
//                                   Text('Rs $totalGiven :آپ نے دیا'),

//                                 ],
//                               );
//                             },
//                onAccept: (data) {
//   final draggedAmount = int.tryParse(data) ?? 0;
//   final requiredCost = activeEvent!['cost'];
//   final provider = context.read<BudgetProvider>();

//   if (provider.budget >= draggedAmount) {
//     setState(() {
//       totalGiven += draggedAmount;
//     });

//     if (totalGiven >= requiredCost) {
//       provider.spend(requiredCost);
//       final extra = totalGiven - requiredCost;
//       setState(() {
//         _score += extra > 0 ? 7 : 10;
//       });

//       String message = extra > 0
//           ? 'آپ نے اضافی رقم دی۔ واپس: Rs $extra'
//           : '🎉 !آپ نے درست رقم دی شاباش';

//       showDialog(
//         context: context,
//         useRootNavigator: false,
//         builder: (dialogContext) => AlertDialog(
//           title: Text('✅ ادائیگی مکمل'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 setState(() {
//                   itemPaid = true;
//                   showEvent = false;
//                   totalGiven = 0;
//                 });
//                 Future.delayed(Duration(milliseconds: 600), _startNextEvent);
//               },
//               child: Text('Next'),
//             )
//           ],
//         ),
//       );
//     }
//   } else {
//     setState(() {
//       _score = max(0, _score - 2);
//     });
//     _showFailure('You do not have enough savings.');
//   }
// },


//                           ),
//                           SizedBox(height: 30),
//                           if (!itemPaid)
//   Wrap(
//     spacing: 10,
//     children: [
//       _buildNoteDraggable('10', 'assets/images/10.jpg'),
//       _buildNoteDraggable('20', 'assets/images/20.jpg'),
//       _buildNoteDraggable('50', 'assets/images/50.jpg'),
//       _buildNoteDraggable('100', 'assets/images/100.jpg'),
//     ],
//   ),

//                         ],
//                       ),
//                     )
//                   : Center(
//                       child: Text('...'),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showFailure(String msg) {
//     showDialog(
//       context: context,
//       useRootNavigator: false,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(msg),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop();
//               _startNextEvent();
//             },
//             child: Text('جاری رکھیں'),
//           )
//         ],
//       ),
//     );
//   }
//   Widget _buildNoteDraggable(String value, String imagePath) {
//   return Draggable<String>(
//     data: value,
//     feedback: Image.asset(imagePath, height: 60),
//     childWhenDragging: Opacity(
//       opacity: 0.3,
//       child: Image.asset(imagePath, height: 60),
//     ),
//     child: Image.asset(imagePath, height: 60),
//   );
// }

// }
// items.dart
class GameItem {
  final String name;
  final String imagePath;
  final int price;

  GameItem({required this.name, required this.imagePath, required this.price});
}

List<GameItem> items = [
  GameItem(name: "Banana", imagePath: "assets/images/banana.png", price: 50),
  GameItem(name: "Soap", imagePath: "assets/images/soap.png", price: 100),
  GameItem(name: "Apple", imagePath: "assets/images/apple.png", price: 20),
  GameItem(name: "Milk", imagePath: "assets/images/milk.png", price: 10),
  GameItem(name: "Ball", imagePath: "assets/images/ball.png", price: 500),


];




