import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/now_playing_bar.dart';
import 'home_screen.dart';
import 'now_playing_screen.dart';
import 'playlists_screen.dart';
import 'favorites_screen.dart';
import 'most_played_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MusicService _musicService = MusicService();
  int _currentIndex = 0;
  MusicTrack? _currentSong;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _musicService.currentSongStream.listen((song) {
      if (mounted) setState(() => _currentSong = song);
    });
    _musicService.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  void _openFullPlayer() {
    if (_currentSong == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NowPlayingScreen(
          song: _currentSong!,
          isPlaying: _isPlaying,
          musicService: _musicService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _musicService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brightPurple = Color(0xFFBE29EC);
    const darkBg = Color(0xFF0A0A0A);
    const surface = Color(0xFF141414);

    return Scaffold(
      backgroundColor: darkBg,
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(musicService: _musicService),
          PlaylistsScreen(musicService: _musicService),
          FavoritesScreen(musicService: _musicService),
          MostPlayedScreen(musicService: _musicService),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: surface,
          border: Border(
            top: BorderSide(color: Color(0xFF222222), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _openFullPlayer,
                child: NowPlayingBar(
                  song: _currentSong,
                  isPlaying: _isPlaying,
                  musicService: _musicService,
                ),
              ),
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: surface,
                selectedItemColor: brightPurple,
                unselectedItemColor: const Color(0xFF888888),
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.playlist_play_outlined),
                    activeIcon: Icon(Icons.playlist_play),
                    label: 'Playlists',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline),
                    activeIcon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.local_fire_department_outlined),
                    activeIcon: Icon(Icons.local_fire_department),
                    label: 'Most Played',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    const lavender = Color(0xFFEFBBFF);
    const surface = Color(0xFF141414);

    return Drawer(
      backgroundColor: surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Vibe Music',
                    style: TextStyle(
                      color: lavender,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF222222), height: 1),
            _drawerItem(
              icon: Icons.queue_music,
              label: 'Queue',
              onTap: () {
                Navigator.pop(context);
                // Queue is shown from now playing
              },
            ),
            _drawerItem(
              icon: Icons.timer,
              label: 'Sleep Timer',
              onTap: () {
                Navigator.pop(context);
                _showSleepTimer(context);
              },
            ),
            _drawerItem(
              icon: Icons.equalizer,
              label: 'Equalizer',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(color: Color(0xFF222222), height: 1),
            _drawerItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.share,
              label: 'Share App',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD896FF), size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _showSleepTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sleep Timer',
                style: TextStyle(
                  color: Color(0xFFEFBBFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coming soon',
                style: TextStyle(color: Color(0xFF888888)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
