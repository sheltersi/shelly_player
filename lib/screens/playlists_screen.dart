import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../widgets/animated_background.dart';

class PlaylistsScreen extends StatefulWidget {
  final MusicService musicService;

  const PlaylistsScreen({super.key, required this.musicService});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
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
          const Icon(Icons.playlist_play, color: Color(0xFFEFBBFF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Playlists',
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

  Widget _buildBody() {
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
              Icons.playlist_add,
              size: 48,
              color: Color(0xFFBE29EC),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Playlists coming soon',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create and manage your playlists here.',
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
