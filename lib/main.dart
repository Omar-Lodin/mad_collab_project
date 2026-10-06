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
  int _hunger = 50;
  int _happiness = 50;
  int energy = 70;
  bool _gameOver = false;
  bool _hasWon = false;
  final TextEditingController _nameController = TextEditingController();

int _clampMeter(int value) => value.clamp(0, 100).toInt();

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

  if (_hungerTimer?.isActive != true) {
    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || _gameOver || _hasWon) {
          timer.cancel();
          return;
        }

        setState(() {
          if (_hunger + 5 > 100) {
            _hunger = 100;
            _happiness = _clampMeter(_happiness - 20);
          } else {
            _hunger += 5;
          }
        });

        _updateOutcome();
      },
    );
  }

   _updateOutcome();
}


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

Widget _meterBar(String label, int value, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value / 100,
          color: color,
          backgroundColor: Colors.grey[300],
          minHeight: 12,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet Lab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
              _meterBar('Hunger', _hunger, Colors.orange),
              _meterBar('Happiness', _happiness, Colors.green),
              _meterBar('Energy', energy, Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _gameOver || _hasWon ? null : _feedPet,
              child: const Text('Feed'),
            ),
            ElevatedButton(
              onPressed: _gameOver || _hasWon ? null : _playWithPet,
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: _gameOver || _hasWon || energy == 100 ? null  : _restPet,
              child: const Text('Rest'),
            ),
            ElevatedButton(
              onPressed: _resetPet,
              child: const Text('Reset'),
            ),
            if (_gameOver)
              const Text(
                'Game Over!',
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
            if (_hasWon)
              const Text(
                'You Won!',
                style: TextStyle(color: Colors.green, fontSize: 24),
              ),
          ],
        ),
      ),
    );
  }
    


Timer? _hungerTimer;
Timer? _highMoodTimer;

void _updateOutcome() {
  if (_gameOver || _hasWon) return;

  if (_hunger == 100 && _happiness <= 10) {
    _highMoodTimer?.cancel();
    _hungerTimer?.cancel();
    setState(() => _gameOver = true);
    return;
  }

  if (_happiness <= 80) {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;
    return;
  }

  _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
    _highMoodTimer = null;
    if (!mounted || _gameOver || _happiness <= 80) return;
    setState(() => _hasWon = true);
    _hungerTimer?.cancel();
  });
}

@override
void initState() {
  super.initState();
  _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    if (!mounted || _gameOver || _hasWon) {
      timer.cancel();
      return;
    }
    setState(() {
      if (_hunger + 5 > 100) {
        _hunger = 100;
        _happiness = _clampMeter(_happiness - 20);
      } else {
        _hunger += 5;
      }
    });
    _updateOutcome();
  });
}

@override
void dispose() {
  _hungerTimer?.cancel();
  _highMoodTimer?.cancel();
  _nameController.dispose();
  super.dispose();
}
}