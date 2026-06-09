import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

class MusicService {
  final AudioPlayer _player = AudioPlayer();

  final StreamController<List<MusicTrack>> _songsController =
      StreamController<List<MusicTrack>>.broadcast();
  final StreamController<MusicTrack?> _currentSongController =
      StreamController<MusicTrack?>.broadcast();

  MusicService() {
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Stream<List<MusicTrack>> get songsStream => _songsController.stream;
  Stream<MusicTrack?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get playingStream => _player.playingStream;
  AudioPlayer get player => _player;

  List<MusicTrack> _songs = [];
  MusicTrack? _currentSong;
  int _currentIndex = -1;
  final List<MusicTrack> _queue = [];

  List<MusicTrack> get songs => List.unmodifiable(_songs);
  MusicTrack? get currentSong => _currentSong;
  List<MusicTrack> get queue => List.unmodifiable(_queue);

  static const _audioExtensions = {
    '.mp3', '.m4a', '.wav', '.flac', '.ogg', '.aac',
    '.wma', '.opus', '.aiff', '.alac',
  };

  static const _maxScanDepth = 4;
  static const _maxFiles = 5000;

  Future<bool> requestPermission() async {
    Permission permission;
    if (Platform.isAndroid) {
      permission = Permission.audio;
    } else {
      permission = Permission.storage;
    }

    var status = await permission.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      return false;
    }

    status = await permission.request();
    return status.isGranted;
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<List<Directory>> _getSearchDirectories() async {
    final dirs = <Directory>[];
    final roots = <String>{};

    try {
      final externalDirs = await getExternalStorageDirectories();
      for (final extDir in externalDirs ?? <Directory>[]) {
        var current = extDir;
        for (int i = 0; i < 4; i++) {
          current = current.parent;
        }
        roots.add(current.path);
      }
    } catch (_) {}

    if (Platform.isAndroid) {
      roots.add('/storage/emulated/0');
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(appDir);
    } catch (_) {}

    for (final root in roots) {
      dirs.add(Directory('$root/Music'));
      dirs.add(Directory('$root/Download'));
      dirs.add(Directory('$root/WhatsApp'));
      dirs.add(Directory('$root/Android/media/com.whatsapp'));
      dirs.add(Directory('$root/Telegram'));
      dirs.add(Directory('$root/Android/media/org.telegram.messenger'));
      dirs.add(Directory('$root/DCIM'));
      dirs.add(Directory('$root/Movies'));
      dirs.add(Directory('$root/Podcasts'));
      dirs.add(Directory('$root/Audiobooks'));
      dirs.add(Directory('$root/Recordings'));
      dirs.add(Directory('$root/Ringtones'));
      dirs.add(Directory('$root/Notifications'));
      dirs.add(Directory('$root/Alarms'));
      dirs.add(Directory('$root/Audio'));
      dirs.add(Directory('$root/Media'));
      dirs.add(Directory('$root/Files'));
      dirs.add(Directory('$root/files'));
      dirs.add(Directory('$root/Bluetooth'));
      dirs.add(Directory('$root/SHAREit'));
      dirs.add(Directory('$root/Xender'));
      dirs.add(Directory('$root/VidMate'));
      dirs.add(Directory('$root/SnapTube'));
      dirs.add(Directory(root));
    }

    return dirs;
  }

  Future<void> scanSongs() async {
    _songs = [];
    final dirs = await _getSearchDirectories();
    final foundFiles = <File>[];
    final seenPaths = <String>{};

    for (final dir in dirs) {
      if (foundFiles.length >= _maxFiles) break;
      await _scanDirectory(dir, foundFiles, seenPaths, 0);
    }

    foundFiles.sort((a, b) {
      final nameA = _titleFromFile(a).toLowerCase();
      final nameB = _titleFromFile(b).toLowerCase();
      return nameA.compareTo(nameB);
    });

    _songs = foundFiles.asMap().entries.map((entry) {
      final file = entry.value;
      return MusicTrack(
        id: entry.key,
        title: _titleFromFile(file),
        artist: 'Unknown Artist',
        album: _parentFolderName(file),
        duration: 0,
        filePath: file.path,
      );
    }).toList();

    _songsController.add(_songs);
    _loadSongDurations();
  }

  Future<void> _scanDirectory(
    Directory dir,
    List<File> foundFiles,
    Set<String> seenPaths,
    int depth,
  ) async {
    if (!await dir.exists() || depth > _maxScanDepth) return;
    if (foundFiles.length >= _maxFiles) return;

    try {
      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (foundFiles.length >= _maxFiles) return;

        if (entity is File) {
          final ext = entity.path.toLowerCase();
          final dotIndex = ext.lastIndexOf('.');
          if (dotIndex == -1) continue;

          final extension = ext.substring(dotIndex);
          if (_audioExtensions.contains(extension) &&
              seenPaths.add(entity.path)) {
            foundFiles.add(entity);
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, foundFiles, seenPaths, depth + 1);
        }
      }
    } catch (_) {}
  }

  String _titleFromFile(File file) {
    final name = file.uri.pathSegments.last;
    final dotIndex = name.lastIndexOf('.');
    final title = dotIndex > 0 ? name.substring(0, dotIndex) : name;
    return title.replaceAll('_', ' ').trim();
  }

  String _parentFolderName(File file) {
    final parent = file.parent;
    final segments = parent.path.split(Platform.pathSeparator);
    return segments.isNotEmpty ? segments.last : 'Unknown';
  }

  Future<void> _loadSongDurations() async {
    final tempPlayer = AudioPlayer();
    for (final song in _songs) {
      if (song.duration > 0) continue;
      try {
        await tempPlayer.setFilePath(song.filePath);
        final dur = tempPlayer.duration;
        song.duration = dur?.inMilliseconds ?? 0;
      } catch (_) {}
    }
    _songsController.add(_songs);
    tempPlayer.dispose();
  }

  Future<void> playSong(MusicTrack song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index == -1) return;

    _currentSong = song;
    _currentIndex = index;
    _currentSongController.add(song);

    await _player.setFilePath(song.filePath);

    if (song.duration == 0) {
      final dur = _player.duration;
      if (dur != null) {
        song.duration = dur.inMilliseconds;
        _songsController.add(_songs);
      }
    }

    _player.play();
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else if (_currentSong != null) {
      await _player.play();
    }
  }

  Future<void> playNext() async {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      final index = _songs.indexWhere((s) => s.id == next.id);
      if (index != -1) {
        await playSong(_songs[index]);
        return;
      }
    }
    if (_songs.isEmpty || _currentIndex >= _songs.length - 1) return;
    await playSong(_songs[_currentIndex + 1]);
  }

  Future<void> playPrevious() async {
    if (_songs.isEmpty || _currentIndex <= 0) return;
    await playSong(_songs[_currentIndex - 1]);
  }

  void addToQueue(MusicTrack song) {
    _queue.add(song);
  }

  void playNextAfterCurrent(MusicTrack song) {
    _queue.insert(0, song);
  }

  Future<void> deleteSong(MusicTrack song) async {
    try {
      final file = File(song.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    _songs.removeWhere((s) => s.id == song.id);
    _songsController.add(List.unmodifiable(_songs));

    if (_currentSong?.id == song.id) {
      _currentSong = null;
      _currentIndex = -1;
      _currentSongController.add(null);
      await _player.stop();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _songsController.close();
    _currentSongController.close();
    _player.dispose();
  }
}
