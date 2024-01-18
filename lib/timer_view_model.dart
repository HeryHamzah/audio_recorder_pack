import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerProvider extends ChangeNotifier {
  late Timer _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isPaused = false;

  Duration get elapsedTime => _elapsedTime;
  bool get isPaused => _isPaused;

  TimerProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (!_isPaused) {
      _elapsedTime += const Duration(seconds: 1);
      notifyListeners();
    }
  }

  void startTimer() {
    _isPaused = false;
    notifyListeners();
  }

  void pauseTimer() {
    _isPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isPaused = false;
    notifyListeners();
  }

  void resetTimer() {
    _elapsedTime = Duration.zero;
    _isPaused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
