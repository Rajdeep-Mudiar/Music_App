import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/providers/data_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/providers/study_provider.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(studyTimerProvider);
    final timerNotifier = ref.read(studyTimerProvider.notifier);
    final studyTracksAsync = ref.watch(studyTracksProvider);
    final studyRoomsAsync = ref.watch(studyRoomsProvider);
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFFF7675), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${timerState.streakDays} Days',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          // Timer Mode Selector (25/5, 50/10, Custom)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(
                title: '25 / 5',
                isSelected: timerState.mode == PomodoroMode.twentyFiveFive,
                onTap: () => timerNotifier.setMode(PomodoroMode.twentyFiveFive),
              ),
              const SizedBox(width: 10),
              _buildModeButton(
                title: '50 / 10',
                isSelected: timerState.mode == PomodoroMode.fiftyTen,
                onTap: () => timerNotifier.setMode(PomodoroMode.fiftyTen),
              ),
              const SizedBox(width: 10),
              _buildModeButton(
                title: 'Custom',
                isSelected: timerState.mode == PomodoroMode.custom,
                onTap: () => timerNotifier.setMode(PomodoroMode.custom),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Glowing Pomodoro Timer Circular Widget
          Center(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.studyGradient,
                boxShadow: [
                  BoxShadow(
                    color: (timerState.isBreak ? AppTheme.neonGreen : AppTheme.primary).withOpacity(0.35),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 210,
                    height: 210,
                    child: CircularProgressIndicator(
                      value: timerState.progress,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.darkBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timerState.isBreak ? AppTheme.neonGreen : AppTheme.secondary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: (timerState.isBreak ? AppTheme.neonGreen : AppTheme.secondary).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          timerState.isBreak ? 'BREAK TIME' : 'DEEP FOCUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: timerState.isBreak ? AppTheme.neonGreen : AppTheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timerState.formattedTime,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed: ${timerState.completedSessionsToday} sessions',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Timer Controls (Start/Pause, Reset)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: timerState.isRunning ? AppTheme.accent : AppTheme.primary,
                  padding: const EdgeInsets.all(16),
                ),
                icon: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (timerState.isRunning) {
                    timerNotifier.pauseTimer();
                  } else {
                    timerNotifier.startTimer();
                  }
                },
              ),
              const SizedBox(width: 18),
              IconButton.outlined(
                iconSize: 24,
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppTheme.darkBorder, width: 1.5),
                  padding: const EdgeInsets.all(14),
                ),
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                onPressed: () => timerNotifier.resetTimer(),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Focus Soundscapes Selector
          const Text(
            'Focus Soundscapes',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          studyTracksAsync.when(
            data: (tracks) => SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final t = tracks[index];
                  final isCurrent = playerState.currentTrack?.id == t.id && playerState.isPlaying;
                  return GestureDetector(
                    onTap: () {
                      ref.read(playerProvider.notifier).playTrack(t, queue: tracks);
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.primary.withOpacity(0.3) : AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? AppTheme.secondary : AppTheme.darkBorder,
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCurrent ? Icons.volume_up : Icons.headphones,
                                color: isCurrent ? AppTheme.secondary : AppTheme.primaryLight,
                                size: 18,
                              ),
                              const Spacer(),
                              Text(
                                t.genre,
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            t.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Active Campus Study Rooms
          const Text(
            'Virtual Campus Study Rooms',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          studyRoomsAsync.when(
            data: (rooms) => Column(
              children: rooms.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school, color: AppTheme.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(r.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text('${r.activeStudentsCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.darkBorder),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
