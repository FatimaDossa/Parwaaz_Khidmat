import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_stats_service.dart';

// ============================================================
// ENTRY POINT — this is what GameStatsScreen's gameRoutes calls
// ============================================================
class LearningNinjaHome extends StatelessWidget {
  const LearningNinjaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF6FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text("🍎 Learning Ninja",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Learn • Play • Practice",
                style: TextStyle(fontSize: 22, color: Colors.black54)),
            const SizedBox(height: 40),
            levelCard(context,
                title: "Level 1",
                subtitle: "Learn Colors",
                emoji: "🍎",
                color: Colors.redAccent,
                screen: const Level1Screen()),
            const SizedBox(height: 20),
            levelCard(context,
                title: "Level 2",
                subtitle: "Colors & Counting",
                emoji: "🧮",
                color: Colors.orange,
                screen: const Level2Screen()),
            const SizedBox(height: 20),
            levelCard(context,
                title: "Level 3",
                subtitle: "Learn Letters A-E",
                emoji: "🔤",
                color: Colors.blue,
                screen: const Level3Screen()),
          ],
        ),
      ),
    );
  }

  Widget levelCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(.15),
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 34, color: Colors.black45),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SHARED MODELS
// ============================================================

/// A recipe for a falling item, before it's positioned on screen.
/// Levels return this; the engine turns it into a FallingItem with x/y.
class ItemTemplate {
  final String display; // emoji or letter text
  final Color color;
  final dynamic value; // whatever the level needs to check matches with

  ItemTemplate({required this.display, required this.color, required this.value});
}

class FallingItem {
  final String display;
  final Color color;
  final dynamic value;
  double x;
  double y;

  FallingItem({
    required this.display,
    required this.color,
    required this.value,
    required this.x,
    required this.y,
  });
}

class LevelStats {
  int completionTime = 0;
  bool completed = false;
  DateTime? finishedAt;
  int totalCorrectTaps = 0;
  int totalWrongTaps = 0;

  void reset() {
    completionTime = 0;
    completed = false;
    finishedAt = null;
    totalCorrectTaps = 0;
    totalWrongTaps = 0;
  }

  @override
  String toString() {
    return 'LevelStats(completionTime: $completionTime, completed: $completed, '
        'finishedAt: $finishedAt, correct: $totalCorrectTaps, wrong: $totalWrongTaps)';
  }
}

// ============================================================
// SHARED ENGINE — every level's State extends this.
// Subclasses only implement the methods in the "abstract" block.
// ============================================================
abstract class FallingGameState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  // ---------- Must be implemented by each level ----------
  String get levelTitle;
  int get numberOfRounds;
  int targetCountForRound(int roundIndex);
  ItemTemplate spawnItemTemplate(int roundIndex, Random random);
  bool isMatch(FallingItem item, int roundIndex);

  /// Compact single-line content shown inside the white instruction bar.
  Widget buildInstructionBar(int roundIndex);

  /// The "Tap ... X" block reused inside both the intro popup and the
  /// "Great Job! Next..." popup (icon/letter + label).
  Widget buildPopupPromptWidget(int roundIndex);

  /// Called whenever the game resets for a replay. Override to re-roll
  /// any randomized round data (e.g. Level 2's random color/count pairs).
  void onGameReset() {}

  /// Firestore partId for this level (e.g. 'level1'), used when saving stats.
  String get partId;

  // ---------- Shared state ----------
  bool showIntroPopup = true;
  bool showRoundCompletePopup = false;
  bool showLevelComplete = false;
  bool showBackConfirmation = false;

  bool get isGameActive =>
      !showIntroPopup &&
      !showRoundCompletePopup &&
      !showLevelComplete &&
      !showBackConfirmation;

  int currentRoundIndex = 0;
  int correctTaps = 0;

  int seconds = 0;
  Timer? _secondsTimer;

  late final Ticker _ticker;
  FallingItem? currentItem;
  double gameAreaWidth = 0;
  double gameAreaHeight = 0;

  final double itemSize = 80;
  final double fallSpeed = 120; // pixels per second
  final Random random = Random();

  Duration _lastElapsed = Duration.zero;

  bool isPaused = false;
  bool _wasPausedBeforeBackDialog = false;

  final LevelStats stats = LevelStats();

  // ---------- Timer ----------
  void _startSecondsTimer() {
    _secondsTimer?.cancel();
    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  String formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String get formattedTime => "⏱ ${formatTime(seconds)}";

  // ---------- Falling engine ----------
  void _spawnNewItem() {
    if (gameAreaWidth == 0) return;

    final template = spawnItemTemplate(currentRoundIndex, random);
    final randomX = random.nextDouble() * (gameAreaWidth - itemSize);

    currentItem = FallingItem(
      display: template.display,
      color: template.color,
      value: template.value,
      x: randomX,
      y: -itemSize,
    );
  }

  void _onTick(Duration elapsed) {
    if (currentItem == null || gameAreaHeight == 0) {
      _lastElapsed = elapsed;
      return;
    }

    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    setState(() {
      currentItem!.y += fallSpeed * dt;
      if (currentItem!.y >= gameAreaHeight - itemSize) {
        _spawnNewItem();
      }
    });
  }

  // ---------- Pause ----------
  void _pauseGameplay() {
    if (isPaused) return;
    isPaused = true;
    _ticker.stop();
    _secondsTimer?.cancel();
  }

  void _resumeGameplay() {
    if (!isPaused) return;
    isPaused = false;
    _lastElapsed = Duration.zero;
    _ticker.start();
    _startSecondsTimer();
  }

  void togglePause() {
    if (!isGameActive) return;
    setState(() {
      isPaused ? _resumeGameplay() : _pauseGameplay();
    });
  }

  // ---------- Back handling ----------
  void handleBackPressed() {
    if (!isGameActive) {
      Navigator.pop(context);
      return;
    }
    _wasPausedBeforeBackDialog = isPaused;
    setState(() {
      if (!isPaused) _pauseGameplay();
      showBackConfirmation = true;
    });
  }

  void continuePlaying() {
    setState(() {
      showBackConfirmation = false;
      if (!_wasPausedBeforeBackDialog) _resumeGameplay();
    });
  }

  void goHome() {
    resetGame();
    Navigator.pop(context);
  }

  // ---------- Tap / round / level completion ----------
  void onItemTapped(FallingItem item) {
    if (isPaused) return;

    if (!isMatch(item, currentRoundIndex)) {
      stats.totalWrongTaps++;
      return;
    }

    setState(() {
      correctTaps++;
      stats.totalCorrectTaps++;

      if (correctTaps >= targetCountForRound(currentRoundIndex)) {
        handleRoundComplete();
      } else {
        _spawnNewItem();
      }
    });
  }

  void handleRoundComplete() async {
    _ticker.stop();
    currentItem = null;

    if (currentRoundIndex >= numberOfRounds - 1) {
      _secondsTimer?.cancel();
      stats.completionTime = seconds;
      stats.completed = true;
      stats.finishedAt = DateTime.now();

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await GameStatsService().updateGamePartStats(
            gameId: 'Learning Ninja',
            userId: userId,
            partId: partId,
            score: (stats.totalCorrectTaps - stats.totalWrongTaps).clamp(0, stats.totalCorrectTaps).toDouble(),
            timeSpent: stats.completionTime.toDouble(),
          );
        } catch (e) {
          debugPrint('Failed to save Learning Ninja stats: $e');
        }
      }

      if (mounted) {
        setState(() => showLevelComplete = true);
      }
    } else {
      setState(() => showRoundCompletePopup = true);
    }
  }

  void goToNextRound() {
    setState(() {
      showRoundCompletePopup = false;
      currentRoundIndex++;
      correctTaps = 0;
    });
    _spawnNewItem();
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  // ---------- Replay ----------
  void resetGame() {
    _secondsTimer?.cancel();
    _ticker.stop();

    setState(() {
      showIntroPopup = true;
      showRoundCompletePopup = false;
      showLevelComplete = false;
      showBackConfirmation = false;

      currentRoundIndex = 0;
      correctTaps = 0;
      seconds = 0;
      currentItem = null;
      isPaused = false;

      stats.reset();
      onGameReset();
    });
  }

  void playAgain() => resetGame();

  void startTimers() {
    seconds = 0;
    _startSecondsTimer();
    _spawnNewItem();
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  // ---------- Lifecycle ----------
  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _secondsTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  // ---------- Shared build ----------
  @override
  Widget build(BuildContext context) {
    final bool hasNextRound = currentRoundIndex < numberOfRounds - 1;

    return PopScope(
      canPop: !isGameActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF6FF),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: handleBackPressed,
                          icon: const Icon(Icons.arrow_back, size: 30),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          levelTitle,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            formattedTime,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: togglePause,
                          icon: Icon(
                            isPaused ? Icons.play_circle : Icons.pause_circle,
                            size: 32,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Instruction bar (level-specific content)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: buildInstructionBar(currentRoundIndex),
                    ),

                    const SizedBox(height: 12),

                    // Game area
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          gameAreaWidth = constraints.maxWidth;
                          gameAreaHeight = constraints.maxHeight;

                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.45),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Stack(
                                children: [
                                  if (currentItem != null)
                                    Positioned(
                                      left: currentItem!.x,
                                      top: currentItem!.y,
                                      child: GestureDetector(
                                        onTap: () => onItemTapped(currentItem!),
                                        child: Text(
                                          currentItem!.display,
                                          style: TextStyle(
                                            fontSize: itemSize,
                                            color: currentItem!.color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Progress (dynamic target count)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            targetCountForRound(currentRoundIndex),
                            (index) => Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                index < correctTaps
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                color: Colors.green,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$correctTaps / ${targetCountForRound(currentRoundIndex)}",
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Intro popup
            if (showIntroPopup)
              Container(
                color: Colors.black38,
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Let's Play!",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        buildPopupPromptWidget(currentRoundIndex),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => showIntroPopup = false);
                              startTimers();
                            },
                            child: const Text("OK",
                                style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Round complete popup
            if (showRoundCompletePopup && hasNextRound)
              Container(
                color: Colors.black38,
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Great Job!",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        const Text("Next...", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 20),
                        buildPopupPromptWidget(currentRoundIndex + 1),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: goToNextRound,
                            child: const Text("OK",
                                style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Level complete screen
            if (showLevelComplete)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🎉", style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 10),
                        const Text("Level Complete!",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "⏱ Finished in ${formatTime(stats.completionTime)}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: playAgain,
                            child: const Text("Play Again",
                                style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Back to Levels",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Back confirmation
            if (showBackConfirmation)
              Container(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Leave Level?",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 14),
                        const Text("Your progress will be lost.",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: continuePlaying,
                            child: const Text("Continue Playing",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: goHome,
                            child: const Text("Go Home",
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LEVEL 1 — Learn Colors (RED, GREEN, YELLOW)
// ============================================================
class Level1Screen extends StatefulWidget {
  const Level1Screen({super.key});
  @override
  State<Level1Screen> createState() => _Level1State();
}

class _Level1State extends FallingGameState<Level1Screen> {
  final List<Map<String, dynamic>> _rounds = [
    {"name": "RED", "color": Colors.red},
    {"name": "GREEN", "color": Colors.green},
    {"name": "YELLOW", "color": Colors.yellow},
  ];

  final List<Map<String, dynamic>> _itemPool = [
    {"emoji": "🍎", "color": Colors.red},
    {"emoji": "🍌", "color": Colors.yellow},
    {"emoji": "🥒", "color": Colors.green},
    {"emoji": "🍅", "color": Colors.red},
    {"emoji": "🥦", "color": Colors.green},
  ];

  @override
  String get levelTitle => "Level 1";

  @override
  String get partId => 'level1';

  @override
  int get numberOfRounds => _rounds.length;

  @override
  int targetCountForRound(int roundIndex) => 5;

  @override
  ItemTemplate spawnItemTemplate(int roundIndex, Random rnd) {
    final chosen = _itemPool[rnd.nextInt(_itemPool.length)];
    return ItemTemplate(
        display: chosen["emoji"], color: chosen["color"], value: chosen["color"]);
  }

  @override
  bool isMatch(FallingItem item, int roundIndex) =>
      item.color == _rounds[roundIndex]["color"];

  @override
  Widget buildInstructionBar(int roundIndex) {
    final round = _rounds[roundIndex];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tap", style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        CircleAvatar(radius: 12, backgroundColor: round["color"]),
        const SizedBox(width: 8),
        Text(round["name"],
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: round["color"])),
        const SizedBox(width: 6),
        const Text("objects", style: TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget buildPopupPromptWidget(int roundIndex) {
    final round = _rounds[roundIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Tap all the", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        CircleAvatar(radius: 34, backgroundColor: round["color"]),
        const SizedBox(height: 20),
        Text(round["name"],
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.bold, color: round["color"])),
      ],
    );
  }
}

// ============================================================
// LEVEL 2 — Colors & Counting (randomized "Tap N Color objects")
// Now covers counts 1-5 (shuffled), and biases spawns toward the target.
// ============================================================
class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});
  @override
  State<Level2Screen> createState() => _Level2State();
}

class _Level2RoundData {
  final String colorName;
  final Color color;
  final int count;
  _Level2RoundData(this.colorName, this.color, this.count);
}

class _Level2State extends FallingGameState<Level2Screen> {
  static const int _totalRounds = 5; // one round per count 1-5

  final List<Map<String, dynamic>> _colorChoices = [
    {"name": "RED", "color": Colors.red},
    {"name": "GREEN", "color": Colors.green},
    {"name": "YELLOW", "color": Colors.yellow},
  ];

  final List<Map<String, dynamic>> _itemPool = [
    {"emoji": "🍎", "color": Colors.red},
    {"emoji": "🍌", "color": Colors.yellow},
    {"emoji": "🥒", "color": Colors.green},
    {"emoji": "🍅", "color": Colors.red},
    {"emoji": "🥦", "color": Colors.green},
  ];

  // Chance that the NEXT falling item matches the current target color.
  // Keeps the wait reasonable without making it a guaranteed freebie.
  static const double _targetSpawnBias = 0.5;

  late List<_Level2RoundData> _rounds;

  @override
  void initState() {
    _rounds = _generateRounds();
    super.initState();
  }

  List<_Level2RoundData> _generateRounds() {
    // Guarantee every count 1-5 appears exactly once, in random order.
    final counts = [1, 2, 3, 4, 5]..shuffle(random);

    return List.generate(_totalRounds, (i) {
      final choice = _colorChoices[random.nextInt(_colorChoices.length)];
      return _Level2RoundData(choice["name"], choice["color"], counts[i]);
    });
  }

  @override
  void onGameReset() {
    _rounds = _generateRounds(); // fresh random counts + colors on replay
  }

  @override
  String get levelTitle => "Level 2";

  @override
  String get partId => 'level2';

  @override
  int get numberOfRounds => _rounds.length;

  @override
  int targetCountForRound(int roundIndex) => _rounds[roundIndex].count;

  @override
  ItemTemplate spawnItemTemplate(int roundIndex, Random rnd) {
    final targetColor = _rounds[roundIndex].color;
    final bool spawnTarget = rnd.nextDouble() < _targetSpawnBias;

    List<Map<String, dynamic>> pool = spawnTarget
        ? _itemPool.where((item) => item["color"] == targetColor).toList()
        : _itemPool.where((item) => item["color"] != targetColor).toList();

    if (pool.isEmpty) pool = _itemPool; // safety fallback

    final chosen = pool[rnd.nextInt(pool.length)];
    return ItemTemplate(
        display: chosen["emoji"], color: chosen["color"], value: chosen["color"]);
  }

  @override
  bool isMatch(FallingItem item, int roundIndex) =>
      item.color == _rounds[roundIndex].color;

  @override
  Widget buildInstructionBar(int roundIndex) {
    final r = _rounds[roundIndex];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tap", style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text("${r.count}",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: r.color)),
        const SizedBox(width: 8),
        CircleAvatar(radius: 12, backgroundColor: r.color),
        const SizedBox(width: 8),
        Text(r.colorName,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: r.color)),
        const SizedBox(width: 6),
        const Text("objects", style: TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget buildPopupPromptWidget(int roundIndex) {
    final r = _rounds[roundIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Tap", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${r.count}",
                style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, color: r.color)),
            const SizedBox(width: 16),
            CircleAvatar(radius: 28, backgroundColor: r.color),
          ],
        ),
        const SizedBox(height: 16),
        Text(r.colorName,
            style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold, color: r.color)),
        const SizedBox(height: 6),
        const Text("objects", style: TextStyle(fontSize: 22)),
      ],
    );
  }
}

// ============================================================
// LEVEL 3 — Letters A-E
// Target count per letter reduced to 3, and spawns bias toward the target.
// ============================================================
class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});
  @override
  State<Level3Screen> createState() => _Level3State();
}

class _Level3State extends FallingGameState<Level3Screen> {
  final List<String> _letters = ["A", "B", "C", "D", "E"];

  final Map<String, Color> _letterColors = {
    "A": Colors.red,
    "B": Colors.blue,
    "C": Colors.green,
    "D": Colors.orange,
    "E": Colors.purple,
  };

  // Chance the NEXT falling letter is the target letter.
  static const double _targetSpawnBias = 0.45;

  @override
  String get levelTitle => "Level 3";

  @override
  String get partId => 'level3';

  @override
  int get numberOfRounds => _letters.length;

  @override
  int targetCountForRound(int roundIndex) => 3; // was 5

  @override
  ItemTemplate spawnItemTemplate(int roundIndex, Random rnd) {
    final targetLetter = _letters[roundIndex];
    final bool spawnTarget = rnd.nextDouble() < _targetSpawnBias;

    String letter;
    if (spawnTarget) {
      letter = targetLetter;
    } else {
      final distractors = _letters.where((l) => l != targetLetter).toList();
      letter = distractors[rnd.nextInt(distractors.length)];
    }

    return ItemTemplate(
      display: letter,
      color: _letterColors[letter]!,
      value: letter,
    );
  }

  @override
  bool isMatch(FallingItem item, int roundIndex) =>
      item.value == _letters[roundIndex];

  @override
  Widget buildInstructionBar(int roundIndex) {
    final letter = _letters[roundIndex];
    final color = _letterColors[letter]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Tap all the", style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Text(letter,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(width: 6),
        const Text("'s", style: TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget buildPopupPromptWidget(int roundIndex) {
    final letter = _letters[roundIndex];
    final color = _letterColors[letter]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Tap all the", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 34,
          backgroundColor: color,
          child: Text(letter,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40)),
        ),
        const SizedBox(height: 20),
        Text("$letter's",
            style:
                TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}