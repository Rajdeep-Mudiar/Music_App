import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/providers/player_provider.dart';

class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen> {
  bool _isShuffle = false;
  bool _isRepeat = false;
  bool _isLiked = false;

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final track = playerState.currentTrack;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No song playing')),
      );
    }

    final totalSeconds = playerState.duration.inSeconds > 0
        ? playerState.duration.inSeconds
        : track.duration;
    final currentSeconds =
        playerState.position.inSeconds.clamp(0, totalSeconds);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF211545), Color(0xFF0B0D17)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 30, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Column(
                      children: [
                        const Text('PLAYING FROM CAMPUS',
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppTheme.textMuted)),
                        Text(track.genre,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () => _showTrackOptions(context, track),
                    ),
                  ],
                ),
                const Spacer(),

                // Large Artwork
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: track.artworkUrl != null
                        ? CachedNetworkImage(
                            imageUrl: track.artworkUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => Container(
                              color: AppTheme.darkCard,
                              child: const Icon(Icons.music_note,
                                  color: AppTheme.secondary, size: 64),
                            ),
                          )
                        : Container(
                            color: AppTheme.darkCard,
                            child: const Icon(Icons.music_note,
                                color: AppTheme.secondary, size: 64),
                          ),
                  ),
                ),
                const Spacer(),

                // Track Info & Like Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? AppTheme.accent : Colors.white70,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() => _isLiked = !_isLiked);
                        if (_isLiked) {
                          ref.read(musicServiceProvider).likeTrack(track.id);
                        } else {
                          ref.read(musicServiceProvider).unlikeTrack(track.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Scrub Bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppTheme.secondary,
                    inactiveTrackColor: AppTheme.darkBorder,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: currentSeconds.toDouble(),
                    min: 0,
                    max: totalSeconds.toDouble() > 0
                        ? totalSeconds.toDouble()
                        : 100,
                    onChanged: (val) {
                      ref
                          .read(playerProvider.notifier)
                          .seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(playerState.position),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                      Text(_formatDuration(Duration(seconds: totalSeconds)),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle,
                          color: _isShuffle
                              ? AppTheme.secondary
                              : AppTheme.textMuted),
                      onPressed: () => setState(() => _isShuffle = !_isShuffle),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          size: 36, color: Colors.white),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).skipPrevious(),
                    ),
                    IconButton.filled(
                      iconSize: 42,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: Icon(playerState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).togglePlay(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          size: 36, color: Colors.white),
                      onPressed: () =>
                          ref.read(playerProvider.notifier).skipNext(),
                    ),
                    IconButton(
                      icon: Icon(Icons.repeat,
                          color: _isRepeat
                              ? AppTheme.secondary
                              : AppTheme.textMuted),
                      onPressed: () => setState(() => _isRepeat = !_isRepeat),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Queue button
                IconButton(
                  icon: const Icon(Icons.queue_music,
                      color: AppTheme.textSecondary),
                  tooltip: 'Queue',
                  onPressed: () =>
                      _showQueueBottomSheet(context, playerState.queue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQueueBottomSheet(BuildContext context, List<Track> queue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
                child: Text('Playing Queue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final t = queue[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.music_note, color: AppTheme.secondary),
                    title: Text(t.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(t.artist,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(t.genre,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textMuted)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackOptions(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.playlist_add, color: AppTheme.secondary),
              title: const Text('Add to Campus Playlist'),
              onTap: () => Navigator.pop(c),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white70),
              title: const Text('Share Song with Friends'),
              onTap: () => Navigator.pop(c),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppTheme.accent),
              title: const Text('Report Content'),
              onTap: () => Navigator.pop(c),
            ),
          ],
        ),
      ),
    );
  }
}
