import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const DigitalPetApp());

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DigitalPetScreen(),
    );
  }
}

class DigitalPetScreen extends StatefulWidget {
  const DigitalPetScreen({super.key});

  @override
  State<DigitalPetScreen> createState() => _DigitalPetScreenState();
}

class _DigitalPetScreenState extends State<DigitalPetScreen> {
  // ==========================================================
  // TEAM 1 - CARE SYSTEM
  // ==========================================================

  int _hunger = 50;
  int _happiness = 50;
  int energy = 70;

  bool _gameOver = false;
  bool _hasWon = false;

  final TextEditingController _nameController =
      TextEditingController();

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  // ==========================================================
  // TEAM 2 - PET PERSONALITY
  // ==========================================================

  String get _petName {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return 'Pip';
    }

    return name;
  }

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

  // ==========================================================
  // TEAM 1 - CARE ACTIONS
  // ==========================================================

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _hunger = _clampMeter(_hunger - 10);
    });

    _updateOutcome();
  }

  void _playWithPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 5);
      energy = _clampMeter(energy - 10);
    });

    _updateOutcome();
  }

  void _restPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      energy = _clampMeter(energy + 20);
      _hunger = _clampMeter(_hunger + 5);
    });

    _updateOutcome();
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _hunger = 50;
      _happiness = 50;
      energy = 70;
      _gameOver = false;
      _hasWon = false;
    });

    // Restart timer if it was stopped by game over/win.
    if (_hungerTimer?.isActive != true) {
      _startCareTimer();
    }
  }

  // ==========================================================
  // CARE TIMER
  // Hunger goes up and happiness goes down every 30 seconds.
  // ==========================================================

  void _startCareTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_gameOver || _hasWon) {
          timer.cancel();
          return;
        }

        setState(() {
          _hunger = _clampMeter(_hunger + 5);
          _happiness = _clampMeter(_happiness - 5);
        });

        _updateOutcome();
      },
    );
  }

  // ==========================================================
  // TEAM 2 - ANIMATED METERS
  // ==========================================================

  Widget _meterBar(
    String label,
    int value,
    Color color,
    bool reduceMotion,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value'),

          const SizedBox(height: 6),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: value / 100,
            ),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, animatedValue, child) {
              return LinearProgressIndicator(
                value: animatedValue,
                color: color,
                backgroundColor: Colors.grey[300],
                minHeight: 12,
                borderRadius: const BorderRadius.all(
                  Radius.circular(6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TEAM 1 - GAME OUTCOME
  // ==========================================================

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    // Game over
    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    // Happiness must stay above 80 for the win timer.
    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    // Start win timer if one is not already running.
    _highMoodTimer ??= Timer(
      const Duration(minutes: 3),
      () {
        _highMoodTimer = null;

        if (!mounted ||
            _gameOver ||
            _happiness <= 80) {
          return;
        }

        setState(() {
          _hasWon = true;
        });

        _hungerTimer?.cancel();
      },
    );
  }

  // ==========================================================
  // SCREEN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // TEAM 2 - Respect reduced-motion accessibility setting.
    final reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet Lab'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ==================================================
              // PET NAME
              // ==================================================

              TextField(
                controller: _nameController,

                onChanged: (value) {
                  setState(() {});
                },

                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TEAM 2 - PET IMAGE
              // ==================================================

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

              // ==================================================
              // TEAM 2 - MOOD
              // ==================================================

              Text(
                'Mood: $_moodLabel',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // TEAM 2 - PET MESSAGE
              // ==================================================

              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),

                child: Text(
                  _petMessage,
                  key: ValueKey(_petMessage),
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // METERS
              // ==================================================

              _meterBar(
                'Hunger',
                _hunger,
                Colors.orange,
                reduceMotion,
              ),

              _meterBar(
                'Happiness',
                _happiness,
                Colors.green,
                reduceMotion,
              ),

              _meterBar(
                'Energy',
                energy,
                Colors.blue,
                reduceMotion,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TEAM 1 - CARE BUTTONS
              // ==================================================

              ElevatedButton(
                onPressed:
                    _gameOver || _hasWon ? null : _feedPet,
                child: const Text('Feed'),
              ),

              ElevatedButton(
                onPressed:
                    _gameOver || _hasWon ? null : _playWithPet,
                child: const Text('Play'),
              ),

              ElevatedButton(
                onPressed:
                    _gameOver ||
                            _hasWon ||
                            energy == 100
                        ? null
                        : _restPet,
                child: const Text('Rest'),
              ),

              ElevatedButton(
                onPressed: _resetPet,
                child: const Text('Reset'),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // OUTCOME TEXT
              // ==================================================

              if (_gameOver)
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (_hasWon)
                const Text(
                  'You Won!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // START TIMER
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _startCareTimer();
  }

  // ==========================================================
  // CLEAN UP
  // ==========================================================

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _nameController.dispose();

    super.dispose();
  }
}