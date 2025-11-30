import 'package:app_nghenhac/data/models/search/album.dart';
import 'package:app_nghenhac/data/models/search/artist.dart';
import 'package:app_nghenhac/data/models/search/playlist.dart';
import 'package:app_nghenhac/data/models/search/song.dart';

import '../../../domain/entities/search/search_result.dart';


class SearchResultModel {
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<PlaylistModel> playlists;
  final String query;
  final int totalResults;

  SearchResultModel({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
    required this.query,
    required this.totalResults,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      songs: json['songs'] != null
          ? (json['songs'] as List)
              .map((song) => SongModel.fromJson(song))
              .toList()
          : [],
      artists: json['artists'] != null
          ? (json['artists'] as List)
              .map((artist) => ArtistModel.fromJson(artist))
              .toList()
          : [],
      albums: json['albums'] != null
          ? (json['albums'] as List)
              .map((album) => AlbumModel.fromJson(album))
              .toList()
          : [],
      playlists: json['playlists'] != null
          ? (json['playlists'] as List)
              .map((playlist) => PlaylistModel.fromJson(playlist))
              .toList()
          : [],
      query: json['query'] ?? '',
      totalResults: json['total_results'] ?? 0,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'songs': songs.map((song) => song.toJson()).toList(),
  //     'artists': artists.map((artist) => artist.toJson()).toList(),
  //     'albums': albums.map((album) => album.toJson()).toList(),
  //     'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
  //     'query': query,
  //     'total_results': totalResults,
  //   };
  // }

  SearchResultEntity toEntity() {
    return SearchResultEntity(
      songs: songs.map((song) => song.toEntity()).toList(),
      artists: artists.map((artist) => artist.toEntity()).toList(),
      albums: albums.map((album) => album.toEntity()).toList(),
      playlists: playlists.map((playlist) => playlist.toEntity()).toList(),
      query: query,
      totalResults: totalResults,
    );
  }
}