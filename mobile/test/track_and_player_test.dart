import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/study_provider.dart';

void main() {
  group('Track Model Tests', () {
    test('Track correctly deserializes from legal provider API format', () {
      final json = {
        'id': 'audius_track_123',
        'title': 'Midnight Campus Lo-Fi',
        'artist': 'Resonance Focus Lab',
        'duration': 185,
        'stream_url':
            'https://api.audius.co/v1/tracks/audius_track_123/stream?app_name=ResonanceCampus',
        'genre': 'Lo-Fi',
        'provider': 'audius',
      };

      final track = Track.fromJson(json);

      expect(track.id, equals('audius_track_123'));
      expect(track.title, equals('Midnight Campus Lo-Fi'));
      expect(track.artist, equals('Resonance Focus Lab'));
      expect(track.duration, equals(185));
      expect(track.provider, equals('audius'));
      expect(track.genre, equals('Lo-Fi'));
    });

    test('StudyTimerState formats time correctly for Pomodoro', () {
      final state = StudyTimerState(
        remainingSeconds: 25 * 60,
        totalSeconds: 25 * 60,
        mode: PomodoroMode.twentyFiveFive,
      );

      expect(state.formattedTime, equals('25:00'));
      expect(state.progress, equals(0.0));

      final halfState = state.copyWith(remainingSeconds: 12 * 60 + 30);
      expect(halfState.formattedTime, equals('12:30'));
      expect(halfState.progress, closeTo(0.5, 0.01));
    });
  });
}
