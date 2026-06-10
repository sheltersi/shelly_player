class Playlist {
  final String id;
  String name;
  final List<int> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  int get songCount => songIds.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds.join(','),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: (json['songIds'] as String).isEmpty
            ? []
            : (json['songIds'] as String).split(',').map(int.parse).toList(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}
