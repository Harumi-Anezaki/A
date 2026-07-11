import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int workDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  int _timeLeft = workDuration;
  bool _isRunning = false;
  bool _isWorkTime = true;
  Timer? _timer;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isWorkTime = !_isWorkTime;
            _timeLeft = _isWorkTime ? workDuration : breakDuration;
            // In a real app, you might want to show a notification or play a sound here.
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkTime ? workDuration : breakDuration;
    });
  }

  void _skipSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkTime = !_isWorkTime;
      _timeLeft = _isWorkTime ? workDuration : breakDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_timeLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isWorkTime ? 'Focus Time' : 'Break Time',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isWorkTime ? Colors.redAccent : Colors.green,
                  ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _timeLeft / (_isWorkTime ? workDuration : breakDuration),
                    strokeWidth: 15,
                    backgroundColor: Colors.grey[300],
                    color: _isWorkTime ? Colors.redAccent : Colors.green,
                  ),
                ),
                Text(
                  _formattedTime,
                  style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _resetTimer,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 20),
                FloatingActionButton.large(
                  onPressed: _toggleTimer,
                  backgroundColor: _isRunning ? Colors.orange : Colors.blue,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _skipSession,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.skip_next),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
