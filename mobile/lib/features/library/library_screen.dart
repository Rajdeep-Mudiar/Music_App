import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/providers/auth_provider.dart';
import 'package:resonance/providers/data_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/widgets/song_tile.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final studyAsync = ref.watch(studyTracksProvider);
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.secondary),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          // Liked Songs Banner Tile
          InkWell(
            onTap: () {
              if (studyAsync.value != null && studyAsync.value!.isNotEmpty) {
                ref
                    .read(playerProvider.notifier)
                    .playTrack(studyAsync.value![0], queue: studyAsync.value);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4834D4), Color(0xFF686DE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liked Songs',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user?.likedSongs.length ?? 8} songs saved',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // User Stats Recap Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Focus Minutes', '${user?.studyMinutes ?? 180}m'),
                Container(height: 30, width: 1, color: AppTheme.darkBorder),
                _buildStatItem('Focus Sessions', '${user?.focusSessions ?? 6}'),
                Container(height: 30, width: 1, color: AppTheme.darkBorder),
                _buildStatItem('Streak', '${user?.studyStreak ?? 4} Days'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Playlists Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Playlists & Mixes',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () {},
                  child: const Text('See all',
                      style: TextStyle(color: AppTheme.secondary))),
            ],
          ),

          // Sample Collaborative and Study Playlists
          _buildPlaylistItem(
            title: 'CSE Night Coding Marathon',
            subtitle: 'Collaborative • 14 tracks • 4 contributors',
            icon: Icons.group_work,
            color: const Color(0xFF6C5CE7),
            onTap: () {
              if (studyAsync.value != null && studyAsync.value!.isNotEmpty) {
                ref
                    .read(playerProvider.notifier)
                    .playTrack(studyAsync.value![0], queue: studyAsync.value);
              }
            },
          ),
          _buildPlaylistItem(
            title: 'Exam Calm Piano & Rain',
            subtitle: 'Study Playlist • 8 tracks',
            icon: Icons.menu_book,
            color: const Color(0xFF00D2D3),
            onTap: () {
              if (studyAsync.value != null && studyAsync.value!.length > 1) {
                ref
                    .read(playerProvider.notifier)
                    .playTrack(studyAsync.value![1], queue: studyAsync.value);
              }
            },
          ),
          _buildPlaylistItem(
            title: 'Hostel Balcony Chill',
            subtitle: 'Campus Public • 12 tracks',
            icon: Icons.nightlife,
            color: const Color(0xFFFF7675),
            onTap: () {
              if (studyAsync.value != null && studyAsync.value!.length > 2) {
                ref
                    .read(playerProvider.notifier)
                    .playTrack(studyAsync.value![2], queue: studyAsync.value);
              }
            },
          ),

          const SizedBox(height: 20),
          const Text('Recently Played',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          studyAsync.when(
            data: (tracks) => Column(
              children: tracks.take(4).map((t) {
                final isPlaying = playerState.currentTrack?.id == t.id &&
                    playerState.isPlaying;
                return SongTile(
                  track: t,
                  isPlaying: isPlaying,
                  onTap: () {
                    ref
                        .read(playerProvider.notifier)
                        .playTrack(t, queue: tracks);
                  },
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.secondary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildPlaylistItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: 'Playlist name (e.g. Algo Sprint)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Created playlist "${controller.text}"')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
