import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/music_service.dart';

class QueueSheet extends StatefulWidget {
  final MusicService musicService;

  const QueueSheet({super.key, required this.musicService});

  @override
  State<QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends State<QueueSheet> {
  List<MusicTrack> _queue = [];
  MusicTrack? _currentSong;

  @override
  void initState() {
    super.initState();
    widget.musicService.queueStream.listen((queue) {
      if (mounted) setState(() => _queue = queue);
    });
    widget.musicService.currentSongStream.listen((song) {
      if (mounted) setState(() => _currentSong = song);
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
                  const Text(
                    'Up Next',
                    style: TextStyle(
                      color: Color(0xFFEFBBFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_queue.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        widget.musicService.clearQueue();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF222222), height: 1),
            Flexible(
              child: _queue.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      itemCount: _queue.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final song = _queue[index];
                        final isCurrent = _currentSong?.id == song.id;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE29EC), Color(0xFF800080)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent ? const Color(0xFFEFBBFF) : Colors.white,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF888888), size: 20),
                            onPressed: () => widget.musicService.removeFromQueue(index),
                          ),
                          dense: true,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music,
            size: 48,
            color: Color(0xFF888888),
          ),
          SizedBox(height: 12),
          Text(
            'Queue is empty',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
