import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/providers/auth_provider.dart';
import 'package:resonance/providers/data_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/widgets/song_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final trendingAsync = ref.watch(trendingTracksProvider);
    final studyAsync = ref.watch(studyTracksProvider);
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, ${user?.name.split(' ').first ?? 'Scholar'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.university ?? 'Gauhati University • Campus Beats',
              style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppTheme.secondary, size: 20),
            ),
            tooltip: 'AI Music Assistant',
            onPressed: () => context.push('/ai-assistant'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingTracksProvider);
          ref.invalidate(studyTracksProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            // Streak & Productivity Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user?.studyStreak ?? 4}-Day Study Streak!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${user?.studyMinutes ?? 180} mins focused this week. Keep the rhythm going!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // Switch to Study tab (index 2)
                        DefaultTabController.of(context).animateTo(2);
                      },
                      child: const Text('Focus',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            // Trending at University Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Trending at Your University',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
            ),
            SizedBox(
              height: 190,
              child: trendingAsync.when(
                data: (tracks) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final t = tracks[index];
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(playerProvider.notifier)
                            .playTrack(t, queue: tracks);
                      },
                      child: Container(
                        width: 130,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: t.artworkUrl ?? '',
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                errorWidget: (c, u, e) => Container(
                                  width: 130,
                                  height: 130,
                                  color: AppTheme.darkCard,
                                  child: const Icon(Icons.music_note,
                                      color: AppTheme.secondary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              t.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.secondary)),
                error: (e, s) =>
                    const Center(child: Text('Unable to load trending tracks')),
              ),
            ),

            // Made for Your Study Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Made for Your Study & Focus',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
            ),
            studyAsync.when(
              data: (tracks) => Column(
                children: tracks.take(5).map((track) {
                  final isCurrentlyPlaying =
                      playerState.currentTrack?.id == track.id &&
                          playerState.isPlaying;
                  return SongTile(
                    track: track,
                    isPlaying: isCurrentlyPlaying,
                    onTap: () {
                      ref
                          .read(playerProvider.notifier)
                          .playTrack(track, queue: tracks);
                    },
                  );
                }).toList(),
              ),
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, s) => const SizedBox.shrink(),
            ),

            // Campus Playlists Cards
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Campus Playlists',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCampusPlaylistCard(
                      title: 'CSE Night Coding',
                      subtitle: 'Synth & Fast Lo-Fi',
                      color: const Color(0xFF6C5CE7),
                      icon: Icons.code,
                      onTap: () {
                        if (studyAsync.value != null &&
                            studyAsync.value!.isNotEmpty) {
                          ref.read(playerProvider.notifier).playTrack(
                              studyAsync.value![0],
                              queue: studyAsync.value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCampusPlaylistCard(
                      title: 'Library Rain Chill',
                      subtitle: 'Ambient Acoustics',
                      color: const Color(0xFF00D2D3),
                      icon: Icons.water_drop,
                      onTap: () {
                        if (studyAsync.value != null &&
                            studyAsync.value!.length > 1) {
                          ref.read(playerProvider.notifier).playTrack(
                              studyAsync.value![1],
                              queue: studyAsync.value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusPlaylistCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
