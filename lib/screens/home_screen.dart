import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/song_tile.dart';
import '../widgets/animated_background.dart';
import '../widgets/song_options_sheet.dart';

enum _ViewMode { all, folders, albums, artists }

class HomeScreen extends StatefulWidget {
  final MusicService musicService;

  const HomeScreen({super.key, required this.musicService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MusicTrack> _songs = [];
  MusicTrack? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isPermanentlyDenied = false;
  _ViewMode _viewMode = _ViewMode.all;
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _initMusic();
  }

  void _setupListeners() {
    widget.musicService.songsStream.listen((songs) {
      if (mounted) setState(() => _songs = songs);
    });
    widget.musicService.currentSongStream.listen((song) {
      if (mounted) setState(() => _currentSong = song);
    });
    widget.musicService.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  Future<void> _initMusic() async {
    final granted = await widget.musicService.requestPermission();
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
    await widget.musicService.scanSongs();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _grantPermission() async {
    setState(() => _isLoading = true);
    final granted = await widget.musicService.requestPermission();
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

  List<MusicTrack> _getFilteredSongs() {
    if (_selectedFolder == null) return _songs;
    return _songs.where((s) => s.album == _selectedFolder).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedBackground(),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_hasPermission && _songs.isNotEmpty) _buildFilterChips(),
              if (_selectedFolder != null) _buildFolderBreadcrumb(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ],
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
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFEFBBFF)),
            onPressed: () => Scaffold.of(context).openDrawer(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = [
      ('All Songs', _ViewMode.all),
      ('Folders', _ViewMode.folders),
      ('Albums', _ViewMode.albums),
      ('Artists', _ViewMode.artists),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            final isSelected = _viewMode == chip.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(chip.$1),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _viewMode = chip.$2;
                      _selectedFolder = null;
                    });
                  }
                },
                backgroundColor: const Color(0xFF141414),
                selectedColor: const Color(0xFF800080),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFBE29EC)
                        : const Color(0xFF222222),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFolderBreadcrumb() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD896FF), size: 20),
            onPressed: () => setState(() => _selectedFolder = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedFolder!,
            style: const TextStyle(
              color: Color(0xFFEFBBFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${_getFilteredSongs().length} ${_getFilteredSongs().length == 1 ? 'track' : 'tracks'}',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
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
                    ? widget.musicService.openSettings
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

    switch (_viewMode) {
      case _ViewMode.all:
        return _buildSongList(_getFilteredSongs());
      case _ViewMode.folders:
        return _selectedFolder == null
            ? _buildFolderList()
            : _buildSongList(_getFilteredSongs());
      case _ViewMode.albums:
        return _buildPlaceholder('Albums view coming soon');
      case _ViewMode.artists:
        return _buildPlaceholder('Artists view coming soon');
    }
  }

  Widget _buildSongList(List<MusicTrack> songs) {
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

  Widget _buildFolderList() {
    final folders = _songs.map((s) => s.album).toSet().toList()..sort();
    return ListView.builder(
      itemCount: folders.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemBuilder: (context, index) {
        final folder = folders[index];
        final count = _songs.where((s) => s.album == folder).length;
        return Card(
          color: const Color(0xFF141414),
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF222222)),
          ),
          child: ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFFD896FF)),
            title: Text(
              folder,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '$count ${count == 1 ? 'song' : 'songs'}',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF888888),
            ),
            onTap: () => setState(() => _selectedFolder = folder),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String message) {
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
              Icons.construction,
              size: 48,
              color: Color(0xFFBE29EC),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }
}
