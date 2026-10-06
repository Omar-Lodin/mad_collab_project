import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const PetPage(),
    );
  }
}

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  // Temporary state so Team 2 can run by itself.
  // Team 1's real state will replace these after the merge.
  String _petName = 'Pip';
  int _happiness = 60;
  int _hunger = 15;
  int energy = 70;
  bool _gameOver = false;
  bool _hasWon = false;

  // TEAM 2 - PET PERSONALITY

  String get _moodLabel {
    if (_happiness > 70) {
      return 'Happy';
    }

    if (_happiness >= 30) {
      return 'Neutral';
    }

    return 'Unhappy';
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    }

    if (_happiness >= 30) {
      return Colors.yellow;
    }

    return Colors.red;
  }

  double get _petScale {
    if (_happiness > 70) {
      return 1.06;
    }

    if (_happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest.';
    }

    if (_hasWon) {
      return 'Best day ever!';
    }

    if (_hunger > 80) {
      return "I'm starving!";
    }

    if (_happiness <= 30) {
      return 'Play with me?';
    }

    if (energy < 20) {
      return 'So sleepy...';
    }

    return "Hi, I'm $_petName!";
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _petName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // TEAM 2 - Mood size and color
                AnimatedScale(
                  scale: _petScale,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _moodColor,
                      BlendMode.modulate,
                    ),
                    child: Image.asset(
                      'assets/Hulk.jpg',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TEAM 2 - Mood text
                Text(
                  'Mood: $_moodLabel',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // TEAM 2 - Pet message animation
                AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  child: Text(
                    _petMessage,
                    key: ValueKey(_petMessage),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Happiness: $_happiness',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 6),

                // TEAM 2 - Animated happiness meter
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: _happiness / 100,
                  ),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                    );
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Hunger: $_hunger',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 6),

                // TEAM 2 - Animated hunger meter
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: _hunger / 100,
                  ),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                    );
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Energy: $energy',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}