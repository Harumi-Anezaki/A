import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with SingleTickerProviderStateMixin {
  static const int workDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  int _timeLeft = workDuration;
  bool _isRunning = false;
  bool _isWorkTime = true;
  Timer? _timer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _pulseController.stop();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _pulseController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            _pulseController.stop();
            _isRunning = false;
            _isWorkTime = !_isWorkTime;
            _timeLeft = _isWorkTime ? workDuration : breakDuration;
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkTime ? workDuration : breakDuration;
    });
  }

  void _skipSession() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _isWorkTime = !_isWorkTime;
      _timeLeft = _isWorkTime ? workDuration : breakDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_timeLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = _isWorkTime ? theme.colorScheme.primary : theme.colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isWorkTime ? 'Focus Session' : 'Short Break',
                  key: ValueKey<bool>(_isWorkTime),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: activeColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isWorkTime ? 'Stay concentrated and productive' : 'Relax and recharge',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
              const SizedBox(height: 60),
              ScaleTransition(
                scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: _timeLeft / (_isWorkTime ? workDuration : breakDuration),
                        strokeWidth: 16,
                        strokeAlign: CircularProgressIndicator.strokeAlignOutside,
                        strokeCap: StrokeCap.round,
                        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                        color: activeColor,
                      ),
                    ),
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(_isRunning ? 0.2 : 0.05),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _formattedTime,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.bodyLarge?.color,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.refresh_rounded,
                    onPressed: _resetTimer,
                    color: theme.disabledColor.withOpacity(0.8),
                    theme: theme,
                  ),
                  const SizedBox(width: 32),
                  InkWell(
                    onTap: _toggleTimer,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: _skipSession,
                    color: theme.disabledColor.withOpacity(0.8),
                    theme: theme,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
