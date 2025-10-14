

import 'package:app_nghenhac/domain/entities/search/artist.dart';

class ArtistModel {
  final String id;
  final String name;
  final String nameLowercase; // Thêm field này
  final String? bio;
  final String? imageUrl;
  final List<String>? genres;
  final int? followers;
  final bool isFollowed;

  ArtistModel({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.genres,
    this.followers,
    this.isFollowed = false,
  }) : nameLowercase = name.toLowerCase();

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'],
      imageUrl: json['image_url'],
      genres: json['genres'] != null 
          ? List<String>.from(json['genres'])
          : null,
      followers: json['followers'],
      isFollowed: json['is_followed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_lowercase': nameLowercase, // Thêm vào JSON
      'bio': bio,
      'image_url': imageUrl,
      'genres': genres,
      'followers': followers,
      'is_followed': isFollowed,
    };
  }

  ArtistEntity toEntity() {
    return ArtistEntity(
      id: id,
      name: name,
      bio: bio,
      imageUrl: imageUrl,
      genres: genres,
      followers: followers,
      isFollowed: isFollowed,
    );
  }
}