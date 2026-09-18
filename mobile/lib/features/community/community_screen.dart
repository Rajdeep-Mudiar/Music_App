import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/community_model.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/providers/data_providers.dart';
import 'package:resonance/providers/player_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(campusFeedProvider);
    final eventsAsync = ref.watch(campusEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Community',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondary,
          labelColor: AppTheme.secondary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Campus Feed'),
            Tab(text: 'Top 10 Chart'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Campus Feed
          feedAsync.when(
            data: (posts) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(campusFeedProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(post, ref);
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Failed to load feed')),
          ),

          // 2. Top 10 Chart
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gauhati University Official Top 10',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    SizedBox(height: 4),
                    Text(
                        'Aggregated listening trends from campus dorms & library halls.',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...[
                {
                  'rank': 1,
                  'title': 'Midnight Campus Lo-Fi',
                  'artist': 'Resonance Focus Lab',
                  'plays': 482
                },
                {
                  'rank': 2,
                  'title': 'DSA Coding Marathon',
                  'artist': 'Algorithmic Chill',
                  'plays': 394
                },
                {
                  'rank': 3,
                  'title': 'Rainy Library Acoustics',
                  'artist': 'Campus Rain Soundscape',
                  'plays': 320
                },
                {
                  'rank': 4,
                  'title': 'Late Night Terminal',
                  'artist': 'Cyber Scholar',
                  'plays': 288
                },
                {
                  'rank': 5,
                  'title': 'Campus Coffee House Chill',
                  'artist': 'Student Union Cafe',
                  'plays': 210
                },
              ].map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${item['rank']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (item['rank'] as int) <= 3
                              ? AppTheme.secondary
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(item['artist'] as String,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${item['plays']} plays',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                );
              }),
            ],
          ),

          // 3. Events
          eventsAsync.when(
            data: (events) => ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final ev = events[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ev.image != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: ev.image!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(ev.date,
                                      style: const TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Spacer(),
                                Text(ev.time,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(ev.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(ev.description,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(ev.location,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMuted))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    backgroundColor: AppTheme.primary,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(communityServiceProvider)
                                        .rsvpEvent(ev.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'RSVP confirmed! See you there 🎵')),
                                    );
                                  },
                                  child: const Text('RSVP',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Failed to load events')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('New Post'),
        onPressed: () => _showCreatePostDialog(context, ref),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.darkCard,
                backgroundImage: post.authorImage != null
                    ? CachedNetworkImageProvider(post.authorImage!)
                    : null,
                child: post.authorImage == null
                    ? const Icon(Icons.person,
                        color: AppTheme.secondary, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(post.university,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.content,
              style: const TextStyle(fontSize: 14, height: 1.35)),
          if (post.songAttachment != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                ref
                    .read(playerProvider.notifier)
                    .playTrack(post.songAttachment!);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill,
                        color: AppTheme.secondary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.songAttachment!.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(post.songAttachment!.artist,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  color:
                      post.isLikedByMe ? AppTheme.accent : AppTheme.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(communityServiceProvider).likePost(post.id);
                  ref.invalidate(campusFeedProvider);
                },
              ),
              Text('${post.likesCount}',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,
                  size: 18, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text('${post.commentsCount}',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Campus Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share what you are listening to or studying...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref
                    .read(communityServiceProvider)
                    .createPost(content: controller.text.trim());
                ref.invalidate(campusFeedProvider);
                if (context.mounted) Navigator.pop(c);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
