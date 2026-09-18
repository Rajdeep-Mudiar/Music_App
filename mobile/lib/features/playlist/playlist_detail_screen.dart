import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/playlist_model.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/data_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/widgets/song_tile.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  final PlaylistModel? initialPlaylist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.initialPlaylist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      body: playlistAsync.when(
        data: (playlist) {
          final effectivePlaylist = playlist ?? initialPlaylist;
          if (effectivePlaylist == null) {
            return const Center(child: Text('Playlist not found'));
          }

          final tracks = effectivePlaylist.songs.map((s) => s.song).toList();
          final totalDurationSeconds =
              tracks.fold<int>(0, (sum, t) => sum + t.duration);
          final totalMinutes = (totalDurationSeconds / 60).round();

          return CustomScrollView(
            slivers: [
              // Sliver App Bar with Artwork Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.darkSurface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    effectivePlaylist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: effectivePlaylist.coverImage ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => Container(
                          color: AppTheme.darkCard,
                          child: const Icon(Icons.music_note,
                              size: 80, color: AppTheme.primary),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                              AppTheme.darkBackground,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Playlist Metadata & Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        effectivePlaylist.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        effectivePlaylist.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              effectivePlaylist.creatorName,
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${tracks.length} tracks • ~$totalMinutes mins',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Play All & Shuffle Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text(
                                'Play All',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: tracks.isNotEmpty
                                  ? () {
                                      ref
                                          .read(playerProvider.notifier)
                                          .playTrack(tracks.first,
                                              queue: tracks);
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.secondary,
                              side: const BorderSide(color: AppTheme.secondary),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.shuffle, size: 18),
                            label: const Text('Shuffle'),
                            onPressed: tracks.isNotEmpty
                                ? () {
                                    final shuffled = List<Track>.from(tracks)
                                      ..shuffle();
                                    ref.read(playerProvider.notifier).playTrack(
                                        shuffled.first,
                                        queue: shuffled);
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.darkBorder),
                    ],
                  ),
                ),
              ),

              // Track List
              if (tracks.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No songs added to this playlist yet.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = effectivePlaylist.songs[index];
                      final track = item.song;
                      final isPlaying =
                          playerState.currentTrack?.id == track.id &&
                              playerState.isPlaying;

                      return SongTile(
                        track: track,
                        isPlaying: isPlaying,
                        onTap: () {
                          ref
                              .read(playerProvider.notifier)
                              .playTrack(track, queue: tracks);
                        },
                      );
                    },
                    childCount: effectivePlaylist.songs.length,
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.secondary),
        ),
        error: (e, s) => Center(
          child: Text('Failed to load playlist: $e'),
        ),
      ),
    );
  }
}
