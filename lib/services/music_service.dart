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

  List<MusicTrack> get songs => List.unmodifiable(_songs);
  MusicTrack? get currentSong => _currentSong;

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

    try {
      final externalDirs = await getExternalStorageDirectories();

      for (final extDir in externalDirs ?? <Directory>[]) {
        final parent = extDir.parent;
        dirs.add(Directory('${parent.path}/Music'));
        dirs.add(Directory('${parent.path}/Download'));
        dirs.add(extDir);
      }
    } catch (_) {}

    try {
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add(appDir);
    } catch (_) {}

    if (Platform.isAndroid) {
      dirs.add(Directory('/storage/emulated/0/Music'));
      dirs.add(Directory('/storage/emulated/0/Download'));
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

  Future<void> playSong(MusicTrack song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index == -1) return;

    _currentSong = song;
    _currentIndex = index;
    _currentSongController.add(song);

    await _player.setFilePath(song.filePath);
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
    if (_songs.isEmpty || _currentIndex >= _songs.length - 1) return;
    await playSong(_songs[_currentIndex + 1]);
  }

  Future<void> playPrevious() async {
    if (_songs.isEmpty || _currentIndex <= 0) return;
    await playSong(_songs[_currentIndex - 1]);
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
