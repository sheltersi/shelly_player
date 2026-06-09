import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/animated_background.dart';

class NowPlayingScreen extends StatefulWidget {
  final MusicTrack song;
  final bool isPlaying;
  final MusicService musicService;

  const NowPlayingScreen({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.musicService,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late MusicTrack _song;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _song = widget.song;
    _isPlaying = widget.isPlaying;
    _setupListeners();
  }

  void _setupListeners() {
    widget.musicService.currentSongStream.listen((song) {
      if (song != null && mounted) {
        setState(() => _song = song);
      }
    });
    widget.musicService.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const Spacer(flex: 2),
                _buildAlbumArt(),
                const SizedBox(height: 40),
                _buildSongInfo(),
                const Spacer(flex: 2),
                _buildControls(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFEFBBFF)),
            onPressed: () => Navigator.pop(context),
            splashRadius: 20,
          ),
          const Expanded(
            child: Text(
              'Now Playing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEFBBFF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF888888)),
            onPressed: () {},
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFBE29EC), Color(0xFF800080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE29EC).withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF800080).withValues(alpha: 0.3),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFd896ff), Color(0xFFbe29ec)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Icon(
            _isPlaying ? Icons.equalizer : Icons.music_note,
            size: 80,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            _song.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFEFBBFF),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _song.artist,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.shuffle,
                onPressed: () {},
                size: 28,
                color: const Color(0xFF888888),
              ),
              _buildControlButton(
                icon: Icons.skip_previous,
                onPressed: () => widget.musicService.playPrevious(),
                size: 36,
                color: const Color(0xFFD896FF),
              ),
              _buildPlayButton(),
              _buildControlButton(
                icon: Icons.skip_next,
                onPressed: () => widget.musicService.playNext(),
                size: 36,
                color: const Color(0xFFD896FF),
              ),
              _buildControlButton(
                icon: Icons.repeat,
                onPressed: () {},
                size: 28,
                color: const Color(0xFF888888),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.35,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBE29EC), Color(0xFFD896FF)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: constraints.maxWidth * 0.35 - 6,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFBBFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFBE29EC),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1:24',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                ),
              ),
              Text(
                '-2:56',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      splashRadius: 24,
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBE29EC), Color(0xFF800080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE29EC).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
        onPressed: () => widget.musicService.playPause(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 36,
      ),
    );
  }
}
