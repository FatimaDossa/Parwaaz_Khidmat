# 🦋 Parwaaz – A Life Skills Training Application

<div align="center">

### An inclusive Flutter application that empowers young individuals with intellectual disabilities through interactive, gamified life skills learning.

**Developed as part of the Khidmat Program at Habib University**

---

### 👥 Team Members

| Name 
|------
| Fatima Dossa 
| Sakina Zehra 
| Afifah Uzair 
**In collaboration with ICAN (Icon for Child & Adult Nurturing)**

</div>

---

# 📖 About the Project

Parwaaz is an inclusive Flutter mobile application designed to support the holistic development of **young individuals aged 15–25 with intellectual disabilities** through engaging, interactive, and accessible educational games.

The application was developed in collaboration with **ICAN (Icon for Child & Adult Nurturing)** under the guidance of **Dr. Sajida Hassan**, who works closely with young women with intellectual disabilities.

After conducting multiple requirement gathering sessions with teachers and facilitators, our team identified a significant gap in accessible educational technology that focuses on practical life skills rather than traditional academic learning.

Parwaaz addresses this challenge by combining:

- 🎮 Interactive gameplay
- 🎨 Visual learning
- ✅ Positive reinforcement
- 📊 Progress tracking
- ♿ Accessible interfaces

to create a meaningful learning experience that encourages confidence, independence, and lifelong learning.

The word **Parwaaz** means **"to fly,"** symbolizing confidence, independence, and growth.

---

# ❓ Problem Statement

Many young adults with intellectual disabilities continue to struggle with everyday activities such as:

- Reading a clock
- Recognizing money
- Shopping independently
- Social etiquette
- Emotional recognition
- Personal hygiene
- Counting
- Alphabet recognition
- Daily decision making

Existing educational applications are often:

- Text-heavy
- Not culturally relevant
- Too complicated
- Designed for younger children
- Lacking accessibility features

These limitations reduce engagement and make independent learning more difficult.

---

# 💡 Solution

Parwaaz transforms life skills education into an enjoyable learning experience using educational games specifically designed around the learning needs of intellectually challenged students.

The application emphasizes:

- Large visual elements
- Bright colors
- Simple interactions
- Drag-and-drop mechanics
- Tap-based gameplay
- Minimal reading requirements
- Positive reinforcement
- Repetition-based learning

Every activity mirrors real-life situations while remaining engaging and easy to understand.

---

# ✨ Features

## 🔐 Authentication

- Firebase Authentication (email & password)
- Secure login
- Individual student accounts, routed to Sunshine or Butterfly mode based on user type

---

## 📈 Dashboard

- Personalized dashboard per mode (Sunshine / Butterfly)
- Per-game, per-level progress tracking
- Average score, average time, and completion count for every game level
- Cloud Firestore integration

---

## ♿ Accessibility

- Large buttons
- Bright visual interface
- Minimal text
- Visual instructions
- Friendly animations
- No harsh fail screens
- Encouraging feedback

---

## ☀ Sunshine Mode

Designed for learners requiring foundational support.

Topics include:

- Colors
- Numbers
- Fruits & vegetables
- Alphabets
- Emotions
- Daily habits

---

## 🦋 Butterfly Mode

Designed for learners ready for advanced life skills.

Topics include:

- Social interactions
- Money handling
- Public vs. private behavior
- School routines
- Emotional situations

---

# 🎮 Games

## ☀ Sunshine Mode

### 🍎 Learning Ninja

A falling-object game reinforcing foundational cognitive skills across three levels:

- **Level 1:** Color recognition (tap falling fruits matching a target color)
- **Level 2:** Colors & counting combined (tap a specific number of a target color)
- **Level 3:** Alphabet recognition (tap falling letters A–E in sequence)

---

### 😊 Emotion Explorer

Students build emotional recognition skills through three connected activities:

- Matching facial expressions to emotion names
- A memory-matching game pairing emotion cards
- Scenario-based emotion guessing (treasure box game)

---

### 🪥 Good Habit Hero

Students practice recognizing and reinforcing healthy daily habits and routines.

---

## 🦋 Butterfly Mode

### 🏫 Back To School

Students explore school-based social scenarios across a classroom behavior sorting game and a playground decision-making game.

---

### 💰 Money Master

A financial literacy game covering recognition and handling of everyday transactions.

---

### 🤝 Social Adventure

Interactive scenarios include:

- **Level 1:** Greetings — choosing the appropriate greeting (salaam, handshake, hug, wave) for different people
- **Level 2:** Public vs. private — sorting everyday activities into the correct category
- **Level 3:** Emotional situations — choosing the kind, appropriate response to social scenarios

---

# 🛠 Tech Stack

### Frontend

- Flutter
- Dart

### Backend

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### State Management

- Native Flutter state management (`StatefulWidget` / `setState`)

### UI

- Material Design
- Custom animations

### Development Tools

- Android Studio
- Visual Studio Code
- Flutter SDK
- Git
- GitHub

---

# 🏗 Project Architecture

```
Flutter App
│
├── Authentication
│      │
│      └── Firebase Authentication
│
├── Dashboard
│      │
│      └── Cloud Firestore (per-game, per-level stats)
│
├── Sunshine Mode
│      ├── Learning Ninja
│      ├── Emotion Explorer
│      └── Good Habit Hero
│
├── Butterfly Mode
│      ├── Back To School
│      ├── Money Master
│      └── Social Adventure
│
└── Progress Tracking
       │
       └── Cloud Firestore
```

---

# 🔥 Firebase Services

The application uses Firebase for backend services.

### Authentication

- Email & Password login
- Secure user accounts

### Cloud Firestore

Stores:

- User profiles (including Sunshine/Butterfly user type)
- Per-game, per-level progress (`game_stats/{gameId}/users/{userId}`)
- Average scores, average times, and completion counts

### Firebase Storage

Stores:

- Images
- Assets
- User-related files

---

# 📂 Folder Structure

```
lib/

├── main.dart
├── firebase_options.dart
│
├── dashboard/
│   ├── sunshine_dashboard.dart
│   └── butterfly_dashboard.dart
│
├── games/
│   ├── learning_ninja_game.dart
│   ├── emotion_game.dart
│   ├── good_habit_hero.dart
│   ├── school_game.dart
│   ├── money_master.dart
│   └── social_adventure_game.dart
│
├── screens/
│   ├── cover_page.dart
│   ├── login_screen.dart
│   └── game_stats_screen.dart
│
├── models/
├── services/
│   └── game_stats_service.dart
│
└── utils/
    └── helper_functions.dart
```

Assets (images, animations) live under the project's top-level `assets/` folder, declared in `pubspec.yaml`.

---

# 🚀 Getting Started

## Prerequisites

Install the following before running the project:

- Flutter SDK (Latest Stable)
- Dart SDK
- Android Studio or VS Code
- Android Emulator or Physical Device
- Firebase Project
- Git

---

# ⚙ Installation

## 1. Clone the Repository

```bash
git clone https://github.com/<your-org-or-username>/Parwaaz_Khidmat.git
```

---

## 2. Navigate to the Project

```bash
cd Parwaaz_Khidmat
```

---

## 3. Install Dependencies

```bash
flutter pub get
```

---

## 4. Verify Flutter Installation

```bash
flutter doctor
```

Resolve any issues shown before continuing.

---

# 🔥 Firebase Configuration

## Android

Place

```
google-services.json
```

inside

```
android/app/
```

---

## iOS

Place

```
GoogleService-Info.plist
```

inside

```
ios/Runner/
```

---

## Generate FlutterFire Configuration

```bash
flutterfire configure
```

This generates

```
lib/firebase_options.dart
```

---

# ▶ Running the App

Run on emulator:

```bash
flutter run
```

---

View available devices:

```bash
flutter devices
```

Run on a specific device:

```bash
flutter run -d <device_id>
```

---

Build APK:

```bash
flutter build apk
```

Release APK:

```bash
flutter build apk --release
```

Build iOS:

```bash
flutter build ios
```

---

# 🌱 Future Improvements

- 🎤 Voice prompts (Urdu & English)
- 🔊 Text-to-Speech support (already integrated for some Sunshine games)
- 🎙 Speech Recognition
- 👩‍🏫 Parent & Teacher dashboards
- 🎯 Adaptive difficulty
- 🤖 AI-powered personalized learning
- 🏆 Rewards & achievements
- 📶 Offline mode
- 🌍 Multilingual support
- 📊 Instructor analytics

---

# ❤️ Impact

Parwaaz is more than an educational application—it is a tool for empowerment.

By making learning engaging, accessible, and culturally relevant, the platform helps young women with intellectual disabilities become more confident, independent, and prepared for everyday life.

The project reflects our belief that technology should be inclusive and designed for everyone.

---

# 🙏 Acknowledgements

Special thanks to:

- **ICAN (Icon for Child & Adult Nurturing)** for partnering with us.
- **Dr. Sajida Hassan** for her invaluable guidance and mentorship.
- The teachers and facilitators at ICAN.
- The students who inspired the design of Parwaaz.
- **Habib University** and the **Khidmat Program** for supporting this project.

---

# 👨‍💻 Authors

### Fatima Dossa

Computer Science
Habib University

---

### Sakina Zehra

Computer Science
Habib University

---

### Afifah Uzair

Computer Science
Habib University

---

# 📜 License

This project was developed as part of the **Khidmat Program at Habib University** for educational and social impact purposes.

Intended for academic and non-commercial use unless otherwise specified.

---

<div align="center">

## 🦋 Parwaaz means *"to fly."*

Our hope is that this application gives every learner a little more confidence, a little more independence, and the opportunity to spread their wings.

**Built with ❤️ using Flutter & Firebase**

</div>
