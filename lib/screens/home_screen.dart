import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/now_playing_bar.dart';
import '../widgets/animated_background.dart';
import '../widgets/song_options_sheet.dart';
import 'now_playing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicService _musicService = MusicService();
  List<MusicTrack> _songs = [];
  MusicTrack? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _initMusic();
  }

  void _setupListeners() {
    _musicService.songsStream.listen((songs) {
      if (mounted) setState(() => _songs = songs);
    });

    _musicService.currentSongStream.listen((song) {
      if (mounted) setState(() => _currentSong = song);
    });

    _musicService.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  Future<void> _initMusic() async {
    final granted = await _musicService.requestPermission();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isPermanentlyDenied = !granted;
      });
    }

    if (granted) {
      await _scanSongs();
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanSongs() async {
    await _musicService.scanSongs();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _grantPermission() async {
    setState(() => _isLoading = true);

    final granted = await _musicService.requestPermission();
    if (!mounted) return;

    if (granted) {
      setState(() {
        _hasPermission = true;
        _isPermanentlyDenied = false;
      });
      await _scanSongs();
    } else {
      setState(() {
        _isLoading = false;
        _isPermanentlyDenied = true;
      });
    }
  }

  @override
  void dispose() {
    _musicService.dispose();
    super.dispose();
  }

  void _onSongTap(MusicTrack song) {
    _musicService.playSong(song);
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

  void _showSongOptions(MusicTrack song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SongOptionsSheet(
        song: song,
        musicService: _musicService,
      ),
    );
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
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: _openFullPlayer,
        child: NowPlayingBar(
          song: _currentSong,
          isPlaying: _isPlaying,
          musicService: _musicService,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBE29EC).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vibe Music',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        color: const Color(0xFFEFBBFF),
                      ),
                ),
                if (!_isLoading && _hasPermission)
                  Text(
                    '${_songs.length} ${_songs.length == 1 ? 'track' : 'tracks'}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFBE29EC),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Scanning your library...',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBE29EC).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.library_music,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isPermanentlyDenied
                    ? 'Storage permission was denied. Please enable it in app settings.'
                    : 'Storage permission is required to scan your music library.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800080),
                  foregroundColor: const Color(0xFFEFBBFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isPermanentlyDenied
                    ? _musicService.openSettings
                    : _grantPermission,
                child: Text(
                  _isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_songs.isEmpty) {
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
                Icons.music_off,
                size: 48,
                color: Color(0xFFBE29EC),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No songs found on your device.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _songs.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemBuilder: (context, index) {
        final song = _songs[index];
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
}
