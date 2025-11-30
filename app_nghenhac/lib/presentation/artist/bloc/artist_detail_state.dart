import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';

abstract class ArtistDetailState {}

class ArtistDetailLoading extends ArtistDetailState {}

class ArtistDetailLoaded extends ArtistDetailState {
  final ArtistEntity artist;
  final List<AlbumEntity> albums;
  final List<SongEntity> songs;

  ArtistDetailLoaded({
    required this.artist,
    required this.albums,
    required this.songs,
  });
}

class ArtistDetailFailure extends ArtistDetailState {
  final String errorMessage;

  ArtistDetailFailure({required this.errorMessage});
}