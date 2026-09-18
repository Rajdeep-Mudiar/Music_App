import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resonance/core/theme/app_theme.dart';
import 'package:resonance/models/track_model.dart';

class SongTile extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.track,
    this.isPlaying = false,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: track.artworkUrl != null
                  ? CachedNetworkImage(
                      imageUrl: track.artworkUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(
                        width: 52,
                        height: 52,
                        color: AppTheme.darkSurface,
                        child: const Icon(Icons.music_note,
                            color: AppTheme.textMuted),
                      ),
                      errorWidget: (c, u, e) => Container(
                        width: 52,
                        height: 52,
                        color: AppTheme.darkSurface,
                        child: const Icon(Icons.music_note,
                            color: AppTheme.textMuted),
                      ),
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      color: AppTheme.darkSurface,
                      child: const Icon(Icons.music_note,
                          color: AppTheme.textMuted),
                    ),
            ),
            const SizedBox(width: 14),

            // Title & Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          isPlaying ? AppTheme.secondary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (track.genre.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            track.genre,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Playing Indicator or Icon
            if (isPlaying)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child:
                    Icon(Icons.equalizer, color: AppTheme.secondary, size: 22),
              ),

            // More Options
            IconButton(
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textMuted, size: 20),
              onPressed: onMoreTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
