import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final MusicTrack song;
  final bool isPlaying;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.isSelected,
    required this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFBE29EC).withValues(alpha: 0.1),
          highlightColor: const Color(0xFFBE29EC).withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF1A0A1A), Color(0xFF141414)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFBE29EC).withValues(alpha: 0.4)
                    : const Color(0xFF222222),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFBE29EC).withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                _buildAlbumArt(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFEFBBFF)
                              : Colors.white,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artist} • ${song.album}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isPlaying)
                  _buildPlayingIndicator()
                else
                  Text(
                    song.formattedDuration,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF555555),
                    size: 18,
                  ),
                  onPressed: onMore,
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBE29EC), Color(0xFF800080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE29EC).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isPlaying ? Icons.equalizer : Icons.music_note,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(0.4),
          _bar(0.7),
          _bar(0.5),
        ],
      ),
    );
  }

  Widget _bar(double heightFactor) {
    return Container(
      width: 3.5,
      height: 20 * heightFactor,
      decoration: BoxDecoration(
        color: const Color(0xFFBE29EC),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
