import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/song.dart';

class SongModel extends Equatable {
  final String id;
  final String title;
  final String? titleLowercase;
  final String artist;
  final String? artistLowercase;
  final String? artistId;
  final String? album;
  final String? albumId;
  final String? coverStoragePath;
  final String? audioStoragePath;
  final int? duration;
  final DateTime? releaseDate;
  final List<String>? genres;
  final bool isFavorite;
  final String? coverUrl;
  final String? audioUrl;

  const SongModel({
    required this.id,
    required this.title,
    this.titleLowercase,
    required this.artist,
    this.artistLowercase,
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

  factory SongModel.fromJson(Map<String, dynamic> json) {
    print('🎵 Creating SongModel from JSON: ${json['id']} - ${json['title']}');
    
    try {
      return SongModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        titleLowercase: json['title_lowercase'],
        artist: json['artist'] ?? '',
        artistLowercase: json['artist_lowercase'],
        artistId: json['artist_id'],
        album: json['album'],
        albumId: json['album_id'],
        coverStoragePath: _extractStoragePath(json['cover_url']),
        audioStoragePath: _extractStoragePath(json['audio_url']),
        duration: _parseDuration(json['duration']),
        releaseDate: _parseDate(json['release_date']),
        genres: json['genres'] != null 
            ? List<String>.from(json['genres'])
            : null,
        isFavorite: json['is_favorite'] ?? false,
        coverUrl: json['cover_url'],
        audioUrl: json['audio_url'],
      );
    } catch (e) {
      print('❌ Error in SongModel.fromJson: $e');
      rethrow;
    }
  }

  static String? _extractStoragePath(dynamic field) {
    if (field == null) return null;
    
    if (field is String) {
      return field;
    } else if (field.toString().contains('DocumentReference')) {
      final path = field.toString();
      final match = RegExp(r'\((.+)\)').firstMatch(path);
      final extractedPath = match?.group(1);
      print('📁 Extracted storage path: $extractedPath');
      return extractedPath;
    }
    
    return field.toString();
  }

  static int? _parseDuration(dynamic duration) {
    if (duration == null) return null;
    if (duration is int) return duration;
    if (duration is String) return int.tryParse(duration);
    if (duration is double) return duration.round();
    print('⚠️ Unknown duration type: ${duration.runtimeType}');
    return null;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date.runtimeType.toString().contains('Timestamp')) {
      return (date as dynamic).toDate();
    }
    return null;
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? titleLowercase,
    String? artist,
    String? artistLowercase,
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
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLowercase: titleLowercase ?? this.titleLowercase,
      artist: artist ?? this.artist,
      artistLowercase: artistLowercase ?? this.artistLowercase,
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

  SongEntity toEntity() {
    return SongEntity(
      id: id,
      title: title,
      artist: artist,
      artistId: artistId,
      album: album,
      albumId: albumId,
      coverStoragePath: coverStoragePath,
      audioStoragePath: audioStoragePath,
      duration: duration,
      releaseDate: releaseDate,
      genres: genres,
      isFavorite: isFavorite,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
    );
  }

  @override
  List<Object?> get props => [
    id, title, titleLowercase, artist, artistLowercase, artistId, 
    album, albumId, coverStoragePath, audioStoragePath, duration, 
    releaseDate, genres, isFavorite, coverUrl, audioUrl
  ];
}