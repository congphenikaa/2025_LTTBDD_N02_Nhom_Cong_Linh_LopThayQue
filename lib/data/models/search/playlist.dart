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
      creatorId: json['creator_id'] ?? json['created_by_id'], // Support both fields
      creatorName: json['creator_name'] ?? json['created_by'], // Support both fields
      trackCount: json['track_count'],
      createdAt: json['created_at'] != null
          ? (json['created_at'].runtimeType.toString().contains('Timestamp')
              ? (json['created_at'] as dynamic).toDate()
              : DateTime.tryParse(json['created_at'].toString()))
          : null,
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'].runtimeType.toString().contains('Timestamp')
              ? (json['updated_at'] as dynamic).toDate()
              : DateTime.tryParse(json['updated_at'].toString()))
          : null,
      isPublic: json['is_public'] ?? false,
      isOwned: json['is_owned'] ?? false,
    );
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