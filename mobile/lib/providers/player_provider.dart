import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/services/audio_player_service.dart';

class PlayerStateModel {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final List<Track> queue;

  bool get hasTrack => currentTrack != null;

  PlayerStateModel({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.queue = const [],
  });

  PlayerStateModel copyWith({
    Track? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    List<Track>? queue,
    bool clearTrack = false,
  }) {
    return PlayerStateModel(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerStateModel> {
  final AudioPlayerService _audioService;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _trackSub;

  PlayerNotifier(this._audioService) : super(PlayerStateModel()) {
    _posSub = _audioService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _durSub = _audioService.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    _stateSub = _audioService.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });

    _trackSub = _audioService.currentTrackStream.listen((track) {
      state = state.copyWith(
        currentTrack: track,
        queue: _audioService.queue,
      );
    });
  }

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    await _audioService.playTrack(track, newQueue: queue);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  Future<void> skipNext() async {
    await _audioService.skipNext();
  }

  Future<void> skipPrevious() async {
    await _audioService.skipPrevious();
  }

  Future<void> seek(Duration pos) async {
    await _audioService.seek(pos);
  }

  void addToQueue(Track track) {
    _audioService.addToQueue(track);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _trackSub?.cancel();
    super.dispose();
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerStateModel>((ref) {
  final audioService = ref.watch(audioPlayerServiceProvider);
  return PlayerNotifier(audioService);
});
