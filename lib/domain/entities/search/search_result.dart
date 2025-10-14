import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';


class SearchResultEntity {
  final List<SongEntity> songs;
  final List<ArtistEntity> artists;
  final List<AlbumEntity> albums;
  final List<PlaylistEntity> playlists;
  final String query;
  final int totalResults;

  SearchResultEntity({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
    required this.query,
    required this.totalResults,
  });

  bool get isEmpty =>
      songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  bool get isNotEmpty => !isEmpty;
}