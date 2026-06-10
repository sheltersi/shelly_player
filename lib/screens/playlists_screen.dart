import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/song_tile.dart';

class PlaylistsScreen extends StatefulWidget {
  final MusicService musicService;

  const PlaylistsScreen({super.key, required this.musicService});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> _playlists = [];
  String? _selectedPlaylistId;

  @override
  void initState() {
    super.initState();
    _playlists = widget.musicService.playlists;
    widget.musicService.playlistsStream.listen((playlists) {
      if (mounted) setState(() => _playlists = playlists);
    });
  }

  void _createPlaylist() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'New Playlist',
          style: TextStyle(color: Color(0xFFEFBBFF)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBE29EC)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                widget.musicService.createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Color(0xFFD896FF))),
          ),
        ],
      ),
    );
  }

  void _renamePlaylist(Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rename Playlist',
          style: TextStyle(color: Color(0xFFEFBBFF)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBE29EC)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != playlist.name) {
                widget.musicService.renamePlaylist(playlist.id, name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Rename', style: TextStyle(color: Color(0xFFD896FF))),
          ),
        ],
      ),
    );
  }

  void _deletePlaylist(Playlist playlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Playlist',
          style: TextStyle(color: Color(0xFFEFBBFF)),
        ),
        content: Text(
          'Delete "${playlist.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              widget.musicService.deletePlaylist(playlist.id);
              if (_selectedPlaylistId == playlist.id) {
                _selectedPlaylistId = null;
              }
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(Playlist playlist) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: Color(0xFFEFBBFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF222222), height: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFFD896FF), size: 24),
                title: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _renamePlaylist(playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deletePlaylist(playlist);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onSongTap(MusicTrack song) {
    widget.musicService.playSong(song);
  }

  Playlist? _selectedPlaylist() {
    if (_selectedPlaylistId == null) return null;
    return widget.musicService.getPlaylist(_selectedPlaylistId!);
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _selectedPlaylist();

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(playlist),
                Expanded(
                  child: playlist != null
                      ? _buildPlaylistDetail(playlist)
                      : _buildPlaylistList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedPlaylistId == null
          ? FloatingActionButton(
              onPressed: _createPlaylist,
              backgroundColor: const Color(0xFFBE29EC),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader(Playlist? selected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (selected != null)
            GestureDetector(
              onTap: () => setState(() => _selectedPlaylistId = null),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFFEFBBFF),
                  size: 20,
                ),
              ),
            )
          else ...[
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
                Icons.playlist_play,
                color: Colors.white,
                size: 24,
              ),
            ),
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
        ],
      ),
    );
  }

  Widget _buildPlaylistList() {
    if (_playlists.isEmpty) {
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
              'No playlists yet',
              style: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to create your first playlist.',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return _buildPlaylistCard(playlist);
      },
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlaylistId = playlist.id),
        onLongPress: () => _showPlaylistOptions(playlist),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBE29EC).withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.playlist_play,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPlaylistOptions(playlist),
                icon: const Icon(Icons.more_vert, color: Color(0xFF888888), size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistDetail(Playlist playlist) {
    final songs = widget.musicService.getPlaylistSongs(playlist.id);

    if (songs.isEmpty) {
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
                Icons.music_note,
                size: 48,
                color: Color(0xFFBE29EC),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No songs in this playlist',
              style: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Long press a song to add it to this playlist.',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: songs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              playlist.name,
              style: const TextStyle(
                color: Color(0xFFEFBBFF),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
        final song = songs[index - 1];
        return SongTile(
          song: song,
          isPlaying: false,
          isSelected: widget.musicService.currentSong?.id == song.id,
          onTap: () => _onSongTap(song),
        );
      },
    );
  }
}
