

// class ClassroomScenarioScreen extends StatefulWidget {
//   const ClassroomScenarioScreen({super.key});

//   @override
//   State<ClassroomScenarioScreen> createState() => _ClassroomScenarioScreenState();
// }

// class _ClassroomScenarioScreenState extends State<ClassroomScenarioScreen>
//     with TickerProviderStateMixin {
//   final FlutterTts flutterTts = FlutterTts();
//   final Random random = Random();

//   final List<Map<String, dynamic>> scenarios = [
//     {'image': 'assets/images/classroom1.jpg', 'description': 'The student is eating in class without permission.', 'isCorrect': false},
//     {'image': 'assets/images/classroom2.jpg', 'description': 'The students are playing with books and making noise.', 'isCorrect': false},
//     {'image': 'assets/images/classroom3.jpg', 'description': 'The student is helping a classmate.', 'isCorrect': true},
//     {'image': 'assets/images/classroom4.jpg', 'description': 'The student is sitting on the table and not on the chair.', 'isCorrect': false},
//     {'image': 'assets/images/classroom5.jpg', 'description': 'The student is listening to the teacher and answering her question.', 'isCorrect': true},
//     {'image': 'assets/images/classroom6.jpg', 'description': 'The student is cheating.', 'isCorrect': false},
//     {'image': 'assets/images/classroom7.jpg', 'description': 'The student is shouting on the teacher.', 'isCorrect': false},
//   ];

//   Set<int> tappedBooks = {};
//   Set<int> answeredBooks = {}; // Track books that have been answered

//   bool showFlashcard = false;
//   int currentIndex = 0;

//   bool isIntroSpeaking = false;
//   bool isSpeaking = false;

//   late ConfettiController _confettiController;
//   late AnimationController _flashcardController;
//   late AnimationController _animationController;
//   List<AnimationController> bookControllers = [];

//   List<Offset> bookPositions = [
//     Offset(150, 230),  // Book 1
//     Offset(220, 230),   // Book 2
//     Offset(25, 280),  // Book 3
//     Offset(200, 280),  // Book 4
//     Offset(250, 350),  // Book 5
//     Offset(30, 350),  // Book 6
//     Offset(120, 490),  // Book 7
//   ];


//   String introText = 'You are in the classroom. Tap on a book to see what happens. Help us decide if what the student is doing is good or not. Let\'s make learning fun!';

//   @override
//   void initState() {
//     super.initState();
//     flutterTts.setSpeechRate(0.4);
//     _confettiController = ConfettiController(duration: const Duration(seconds: 4));
//     _flashcardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500), lowerBound: 0.8, upperBound: 1.0);
//     _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
//      // Create a separate animation controller for each book
//     bookControllers = List.generate(scenarios.length, (index) => AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     ));
//     _showIntroOverlay();
//   }


//   void _showIntroOverlay() async {
//     setState(() => isIntroSpeaking = true);

//     bool localIntroCompleted = false;
//     bool localIsSpeaking = true;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setStateDialog) {
//           flutterTts.setCompletionHandler(() {
//             setStateDialog(() {
//               localIsSpeaking = false;
//               localIntroCompleted = true;
//             });
//           });

//           return AlertDialog(
//             title: const Text('Classroom Scenarios'),
//             content: Text(
//               introText,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: localIsSpeaking ? Colors.orange : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: localIntroCompleted ? () => Navigator.of(context).pop() : null,
//                 child: const Text('Start'),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     await flutterTts.speak(introText);
//   }

//   void _speakCurrentScenario() async {
//     setState(() => isSpeaking = true);
//     await flutterTts.stop();
//     await flutterTts.speak(scenarios[currentIndex]['description']);
//     flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
//   }

//   // void _handleAnswer(bool answer) async {
//   //   bool isCorrect = scenarios[currentIndex]['isCorrect'];

//   //   if (answer == isCorrect) {
//   //     await flutterTts.speak('Well done! That is the correct behavior.');
//   //   } else {
//   //     await flutterTts.speak('Oops, that is not the correct behavior.');
//   //   }

//   //   setState(() {
//   //     showFlashcard = false;
//   //     answeredBooks.add(currentIndex); // Remove book only after answering
//   //   });

//   //   if (answeredBooks.length == scenarios.length) {
//   //     await flutterTts.speak('You have completed all the classroom scenarios!');
//   //     _showCompletionDialog();
//   //   }
//   // }

//   void showTemporaryMessage(String message,Color color, {
//     Duration duration = const Duration(seconds: 4),
//     VoidCallback? onComplete,}) {
//     final overlay = Overlay.of(context);
//     final overlayEntry = OverlayEntry(
//       builder: (context) => Center(
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 42),
//             decoration: BoxDecoration(
//               color: Colors.black.withAlpha((0.3 * 255).round()),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 )
//               ],
//             ),
//             child: Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 52,
//                 color: color,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     overlay.insert(overlayEntry);

//     Future.delayed(duration, () {
//       if (mounted) {
//         overlayEntry.remove();
//         if (onComplete != null) onComplete(); // trigger callback after removal
//       }
//     });
//   }

//   void showConfetti(){
//     Lottie.asset("assets/animations/Confetti.json", repeat: false);
//   }

//   void _handleAnswer(bool answer) async {
//     bool isCorrect = scenarios[currentIndex]['isCorrect'];

//     if (answer == isCorrect) {
//       showTemporaryMessage("Correct!", Colors.green);
//       showConfetti();
//       await flutterTts.speak('Well done! That is the correct behavior.');
//     } else {
//       showTemporaryMessage("Try again!", Colors.red);
//       await flutterTts.speak('Oops, that is not the correct behavior.');
//     }

//     setState(() {
//       showFlashcard = false;
//       answeredBooks.add(currentIndex); // Remove book only after answering
//     });

//     if (answeredBooks.length == scenarios.length) {
//       await flutterTts.speak('You have completed all the classroom scenarios!');
//       _showCompletionDialog();
//     }
//   }



//   void _showCompletionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Complete!'),
//         content: const Text('You have successfully completed this location.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop();
//             },
//             child: const Text('Back to Map'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     _flashcardController.dispose();
//     _animationController.dispose();
//     flutterTts.stop();
//     for (var controller in bookControllers) {
//     controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Classroom Scenarios')),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset('assets/images/classroom_bg3.jpg', fit: BoxFit.cover),
//           ),

//           ...List.generate(bookPositions.length, (index) {
//           if (answeredBooks.contains(index)) return const SizedBox.shrink();

//           return Positioned(
//             left: bookPositions[index].dx,
//             top: bookPositions[index].dy,
//             child: GestureDetector(
//               onTap: () async {
//                 if (tappedBooks.contains(index)) return;
//                 bookControllers[index].forward();
//                 await Future.delayed(const Duration(seconds: 1));
//                 setState(() {
//                   tappedBooks.add(index); // Track tapped books to prevent re-tap
//                   currentIndex = index;
//                   showFlashcard = true;
//                 });

//                 _flashcardController.forward(from: 0.8);
//                 _speakCurrentScenario();
//               },
//               child: SizedBox(
//                 width: 80.w,
//                 height: 80.w,
//                 child: Lottie.asset(
//                   'assets/animations/book_open.json',
//                   controller: bookControllers[index],
//                   animate: false,
//                   onLoaded: (composition) {
//                     bookControllers[index].duration = composition.duration;
//                   },
//                 ),
//               ),
//             ),
//           );
//         }),


//           // // Confetti
//           // Align(
//           //   alignment: Alignment.topCenter,
//           //   child: ConfettiWidget(
//           //     confettiController: _confettiController,
//           //     blastDirectionality: BlastDirectionality.explosive,
//           //     shouldLoop: false,
//           //     colors: const [Colors.green, Colors.blue, Colors.pink],
//           //   ),
//           // ),

//           // Flashcard Popup
//           if (showFlashcard)
//             Center(
//               child: ScaleTransition(
//                 scale: _flashcardController,
//                 child: Card(
//                   elevation: 10,
//                   shadowColor: Colors.grey.withOpacity(0.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                     side: BorderSide(color: Colors.blueAccent, width: 2),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(12.w),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.asset(
//                           scenarios[currentIndex]['image'],
//                           width: 300.w,
//                           height: 300.w,
//                           fit: BoxFit.contain,
//                         ),
//                         SizedBox(height: 20.h),
//                         Container(
//                           padding: EdgeInsets.all(10.w),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.8),
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           child: Text(
//                             scenarios[currentIndex]['description'],
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 24.sp,
//                               fontWeight: FontWeight.bold,
//                               color: isSpeaking ? Colors.blue : Colors.black,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
//                                 textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//                               ),
//                               onPressed: () => _handleAnswer(true),
//                               child: const Text('Good'),
//                             ),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
//                                 textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//                               ),
//                               onPressed: () => _handleAnswer(false),
//                               child: const Text('Bad'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }