import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/track_model.dart';
import 'package:resonance/providers/core_providers.dart';
import 'package:resonance/providers/player_provider.dart';
import 'package:resonance/widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Track> _searchResults = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Focus & Lo-Fi', 'Campus Beats', 'Classical', 'Podcasts'];

  final List<String> _trendingSearches = [
    'Lo-Fi Study',
    'Coding Synth',
    'Rain Ambience',
    'Exam Calm',
    'Hostel Vibes',
    'Deep Focus'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isLoading = true);
      final musicService = ref.read(musicServiceProvider);
      final results = await musicService.searchTracks(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Songs, artists, study vibes, campus charts...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.secondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.darkSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.darkBorder),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedFilter = filter);
                      if (filter != 'All') {
                        _searchController.text = filter;
                        _onSearchChanged(filter);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Body: Results or Trending Searches
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
                : _searchResults.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final track = _searchResults[index];
                          final isPlaying = playerState.currentTrack?.id == track.id && playerState.isPlaying;
                          return SongTile(
                            track: track,
                            isPlaying: isPlaying,
                            onTap: () {
                              ref.read(playerProvider.notifier).playTrack(track, queue: _searchResults);
                            },
                          );
                        },
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          const Text(
                            'Trending Campus Searches',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _trendingSearches.map((term) {
                              return ActionChip(
                                label: Text(term),
                                backgroundColor: AppTheme.darkSurface,
                                labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppTheme.darkBorder),
                                ),
                                onPressed: () {
                                  _searchController.text = term;
                                  _onSearchChanged(term);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
