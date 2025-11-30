import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:equatable/equatable.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';


abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SongEntity> songs;
  final List<ArtistEntity> artists;
  final List<AlbumEntity> albums;
  final List<PlaylistEntity> playlists;
  
  const SearchSuccess({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.playlists,
  });
  
  @override
  List<Object?> get props => [songs, artists, albums, playlists];
}

class SearchFailure extends SearchState {
  final String message;
  
  const SearchFailure({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class SearchEmpty extends SearchState {}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;
  
  const SearchHistoryLoaded({required this.history});
  
  @override
  List<Object?> get props => [history];
}