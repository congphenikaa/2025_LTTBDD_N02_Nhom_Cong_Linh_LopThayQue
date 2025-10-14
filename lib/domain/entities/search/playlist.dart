class PlaylistEntity {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? creatorId;
  final String? creatorName;
  final int? trackCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final bool isOwned;

  PlaylistEntity({
    required this.id,
    required this.name,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}