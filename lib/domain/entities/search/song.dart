class SongEntity {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final String? albumId;
  final String? coverStoragePath;  // Storage path thay vì URL
  final String? audioStoragePath;  // Storage path thay vì URL
  final int? duration; // in seconds
  final DateTime? releaseDate;
  final List<String>? genres;
  final bool isFavorite;

  // Cached URLs (sẽ được load từ Firebase Storage)
  final String? coverUrl;
  final String? audioUrl;

  SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.coverStoragePath,
    this.audioStoragePath,
    this.duration,
    this.releaseDate,
    this.genres,
    this.isFavorite = false,
    this.coverUrl,
    this.audioUrl,
  });

  // Copy with method để update URLs
  SongEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    String? coverStoragePath,
    String? audioStoragePath,
    int? duration,
    DateTime? releaseDate,
    List<String>? genres,
    bool? isFavorite,
    String? coverUrl,
    String? audioUrl,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      audioStoragePath: audioStoragePath ?? this.audioStoragePath,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      isFavorite: isFavorite ?? this.isFavorite,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}