import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/playlist.dart';

class PlaylistModel extends Equatable {
  final String id;
  final String name;
  final String? nameLowercase;
  final String? description;
  final String? coverUrl;
  final String? creatorId;
  final String? creatorName;
  final int? trackCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final bool isOwned;

  const PlaylistModel({
    required this.id,
    required this.name,
    this.nameLowercase,
    this.description,
    this.coverUrl,
    this.creatorId,
    this.creatorName,
    this.trackCount,
    this.createdAt,
    this.updatedAt,
    this.isPublic = false,
    this.isOwned = false,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameLowercase: json['name_lowercase'],
      description: json['description'],
      coverUrl: json['cover_url'],
      creatorId: json['creator_id'],
      creatorName: json['creator_name'], 
      trackCount: _parseTrackCount(json['track_count']), // ✅ Safe parsing
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
      isPublic: json['is_public'] ?? false,
      isOwned: json['is_owned'] ?? false,
    );
  }

  // ✅ Safe parsing methods
  static int? _parseTrackCount(dynamic trackCount) {
    if (trackCount == null) return null;
    if (trackCount is int) return trackCount;
    if (trackCount is String) return int.tryParse(trackCount);
    if (trackCount is double) return trackCount.round();
    return null;
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp.runtimeType.toString().contains('Timestamp')) {
      return (timestamp as dynamic).toDate();
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
  PlaylistEntity toEntity() {
    return PlaylistEntity(
      id: id,
      name: name,
      description: description,
      coverUrl: coverUrl,
      creatorId: creatorId,
      creatorName: creatorName,
      trackCount: trackCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPublic: isPublic,
      isOwned: isOwned,
    );
  }

  @override
  List<Object?> get props => [
    id, name, nameLowercase, description, coverUrl, 
    creatorId, creatorName, trackCount, createdAt, updatedAt, isPublic, isOwned
  ];
}