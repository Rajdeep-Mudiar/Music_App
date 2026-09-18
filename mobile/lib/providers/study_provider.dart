import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/services/study_service.dart';

enum PomodoroMode {
  twentyFiveFive,
  fiftyTen,
  custom,
}

class StudyTimerState {
  final bool isRunning;
  final bool isBreak;
  final int remainingSeconds;
  final int totalSeconds;
  final PomodoroMode mode;
  final int completedSessionsToday;
  final int streakDays;

  double get progress => totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;
  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  StudyTimerState({
    this.isRunning = false,
    this.isBreak = false,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.mode = PomodoroMode.twentyFiveFive,
    this.completedSessionsToday = 0,
    this.streakDays = 4,
  });

  StudyTimerState copyWith({
    bool? isRunning,
    bool? isBreak,
    int? remainingSeconds,
    int? totalSeconds,
    PomodoroMode? mode,
    int? completedSessionsToday,
    int? streakDays,
  }) {
    return StudyTimerState(
      isRunning: isRunning ?? this.isRunning,
      isBreak: isBreak ?? this.isBreak,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      mode: mode ?? this.mode,
      completedSessionsToday: completedSessionsToday ?? this.completedSessionsToday,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class StudyTimerNotifier extends StateNotifier<StudyTimerState> {
  final StudyService _studyService;
  Timer? _timer;

  StudyTimerNotifier(this._studyService) : super(StudyTimerState());

  void startTimer() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onSessionComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    int secs = _getFocusSeconds(state.mode);
    state = state.copyWith(
      isRunning: false,
      isBreak: false,
      remainingSeconds: secs,
      totalSeconds: secs,
    );
  }

  void setMode(PomodoroMode mode) {
    _timer?.cancel();
    int secs = _getFocusSeconds(mode);
    state = state.copyWith(
      mode: mode,
      isRunning: false,
      isBreak: false,
      remainingSeconds: secs,
      totalSeconds: secs,
    );
  }

  void _onSessionComplete() {
    _timer?.cancel();
    if (!state.isBreak) {
      // Focus session ended -> log to backend and switch to break
      final durationMin = state.totalSeconds ~/ 60;
      _studyService.logSession(durationMinutes: durationMin, sessionType: 'pomodoro');

      final breakSecs = state.mode == PomodoroMode.fiftyTen ? 10 * 60 : 5 * 60;
      state = state.copyWith(
        isRunning: false,
        isBreak: true,
        remainingSeconds: breakSecs,
        totalSeconds: breakSecs,
        completedSessionsToday: state.completedSessionsToday + 1,
      );
    } else {
      // Break ended -> switch back to focus
      final focusSecs = _getFocusSeconds(state.mode);
      state = state.copyWith(
        isRunning: false,
        isBreak: false,
        remainingSeconds: focusSecs,
        totalSeconds: focusSecs,
      );
    }
  }

  int _getFocusSeconds(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.twentyFiveFive:
        return 25 * 60;
      case PomodoroMode.fiftyTen:
        return 50 * 60;
      case PomodoroMode.custom:
        return 45 * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final studyTimerProvider = StateNotifierProvider<StudyTimerNotifier, StudyTimerState>((ref) {
  final service = ref.watch(studyServiceProvider);
  return StudyTimerNotifier(service);
});
