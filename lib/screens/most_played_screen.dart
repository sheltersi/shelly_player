import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/animated_background.dart';
import '../widgets/song_options_sheet.dart';

class MostPlayedScreen extends StatefulWidget {
  final MusicService musicService;

  const MostPlayedScreen({super.key, required this.musicService});

  @override
  State<MostPlayedScreen> createState() => _MostPlayedScreenState();
}

class _MostPlayedScreenState extends State<MostPlayedScreen> {
  MusicTrack? _currentSong;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.musicService.songsStream.listen((_) {
      if (mounted) setState(() {});
    });
    widget.musicService.currentSongStream.listen((song) {
      if (mounted) setState(() => _currentSong = song);
    });
    widget.musicService.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  void _onSongTap(MusicTrack song) {
    widget.musicService.playSong(song);
  }

  void _showSongOptions(MusicTrack song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SongOptionsSheet(
        song: song,
        musicService: widget.musicService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mostPlayed = widget.musicService.getMostPlayed();

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: mostPlayed.isEmpty
                      ? _buildEmpty()
                      : _buildList(mostPlayed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFEFBBFF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Most Played',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    color: const Color(0xFFEFBBFF),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MusicTrack> songs) {
    return ListView.builder(
      itemCount: songs.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemBuilder: (context, index) {
        final song = songs[index];
        final isSelected = _currentSong?.id == song.id;
        return SongTile(
          song: song,
          isPlaying: isSelected && _isPlaying,
          isSelected: isSelected,
          onTap: () => _onSongTap(song),
          onMore: () => _showSongOptions(song),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFBE29EC).withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.local_fire_department,
              size: 48,
              color: Color(0xFFBE29EC),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No play history yet.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Play some songs and they will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }
}
