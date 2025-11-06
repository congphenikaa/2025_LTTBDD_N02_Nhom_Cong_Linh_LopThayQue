import 'package:equatable/equatable.dart';
import '../../../domain/entities/search/album.dart';
import '../../../domain/entities/search/song.dart';

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object?> get props => [];
}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final AlbumEntity album;
  final List<SongEntity> songs;

  const AlbumLoaded({
    required this.album,
    required this.songs,
  });

  @override
  List<Object?> get props => [album, songs];
}

class AlbumLoadFailure extends AlbumState {
  final String message;

  const AlbumLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlbumSongPlaying extends AlbumLoaded {
  final int currentSongIndex;
  final bool isPlaying;

  const AlbumSongPlaying({
    required AlbumEntity album,
    required List<SongEntity> songs,
    required this.currentSongIndex,
    required this.isPlaying,
  }) : super(album: album, songs: songs);

  @override
  List<Object?> get props => [album, songs, currentSongIndex, isPlaying];
}