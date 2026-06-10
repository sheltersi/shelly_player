import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';

class SongOptionsSheet extends StatefulWidget {
  final MusicTrack song;
  final MusicService musicService;

  const SongOptionsSheet({
    super.key,
    required this.song,
    required this.musicService,
  });

  @override
  State<SongOptionsSheet> createState() => _SongOptionsSheetState();
}

class _SongOptionsSheetState extends State<SongOptionsSheet> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.musicService.isFavorite(widget.song.id);
    widget.musicService.favoritesStream.listen((favs) {
      if (mounted) {
        setState(() => _isFavorite = favs.contains(widget.song.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFEFBBFF),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.song.artist} \u2022 ${widget.song.album}',
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF222222), height: 1),
            _buildOption(
              icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
              label: _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              color: _isFavorite ? Colors.redAccent : const Color(0xFFD896FF),
              onTap: () {
                widget.musicService.toggleFavorite(widget.song.id);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              icon: Icons.play_arrow,
              label: 'Play Next',
              onTap: () {
                widget.musicService.playNextAfterCurrent(widget.song);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              icon: Icons.queue_music,
              label: 'Add to Queue',
              onTap: () {
                widget.musicService.addToQueue(widget.song);
                Navigator.pop(context);
              },
            ),
            _buildOption(
              icon: Icons.playlist_add,
              label: 'Add to Playlist',
              onTap: () => _showPlaylistPicker(context),
            ),
            _buildOption(
              icon: Icons.share,
              label: 'Share',
              onTap: () => _share(context),
            ),
            _buildOption(
              icon: Icons.info_outline,
              label: 'Song Info',
              onTap: () => _showSongInfo(context),
            ),
            _buildOption(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: Colors.redAccent,
              onTap: () => _showDeleteConfirm(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFFD896FF),
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: color == Colors.redAccent ? Colors.redAccent : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  Future<void> _share(BuildContext context) async {
    final file = File(widget.song.filePath);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not found'),
            backgroundColor: Color(0xFF1A0A1A),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    try {
      await Share.shareXFiles([XFile(widget.song.filePath)], text: widget.song.title);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not share file'),
            backgroundColor: Color(0xFF1A0A1A),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _showPlaylistPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return _PlaylistPickerDialog(
          song: widget.song,
          musicService: widget.musicService,
        );
      },
    );
  }

  void _showSongInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Song Info',
          style: TextStyle(color: Color(0xFFEFBBFF)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', widget.song.title),
            _infoRow('Artist', widget.song.artist),
            _infoRow('Album', widget.song.album),
            _infoRow('Duration', _formatMillis(widget.song.duration)),
            _infoRow('File', widget.song.filePath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Close', style: TextStyle(color: Color(0xFFD896FF))),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Song',
          style: TextStyle(color: Color(0xFFEFBBFF)),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.song.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await widget.musicService.deleteSong(widget.song);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMillis(int ms) {
    if (ms <= 0) return '0:00';
    final minutes = Duration(milliseconds: ms).inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = Duration(milliseconds: ms).inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlaylistPickerDialog extends StatelessWidget {
  final MusicTrack song;
  final MusicService musicService;

  const _PlaylistPickerDialog({
    required this.song,
    required this.musicService,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Add to Playlist',
        style: TextStyle(color: Color(0xFFEFBBFF)),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Playlist>>(
          stream: musicService.playlistsStream,
          initialData: musicService.playlists,
          builder: (context, snapshot) {
            final playlists = snapshot.data ?? [];
            if (playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No playlists yet. Create one below.',
                  style: TextStyle(color: Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: playlists.map((playlist) {
                final isInPlaylist =
                    playlist.songIds.contains(song.id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isInPlaylist ? Icons.check : Icons.playlist_play,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                  ),
                  trailing: Icon(
                    isInPlaylist ? Icons.remove_circle_outline : Icons.add_circle_outline,
                    color: isInPlaylist ? Colors.redAccent : const Color(0xFFD896FF),
                  ),
                  onTap: () {
                    if (isInPlaylist) {
                      musicService.removeFromPlaylist(playlist.id, song.id);
                    } else {
                      musicService.addToPlaylist(playlist.id, song.id);
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _showCreatePlaylistDialog(context);
          },
          child: const Text(
            'Create New',
            style: TextStyle(color: Color(0xFFD896FF)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Done',
            style: TextStyle(color: Color(0xFF888888)),
          ),
        ),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final playlist = musicService.createPlaylist(name);
                musicService.addToPlaylist(playlist.id, song.id);
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Create', style: TextStyle(color: Color(0xFFD896FF))),
          ),
        ],
      ),
    );
  }
}
