import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlbumDetails extends AlbumEvent {
  final String albumId;

  const LoadAlbumDetails({required this.albumId});

  @override
  List<Object?> get props => [albumId];
}

class PlaySong extends AlbumEvent {
  final int songIndex;

  const PlaySong({required this.songIndex});

  @override
  List<Object?> get props => [songIndex];
}

class PauseSong extends AlbumEvent {}

class ResumeSong extends AlbumEvent {}

class NextSong extends AlbumEvent {}

class PreviousSong extends AlbumEvent {}

class ToggleFavoriteAlbum extends AlbumEvent {
  final String albumId;

  const ToggleFavoriteAlbum({required this.albumId});

  @override
  List<Object?> get props => [albumId];
}

class ToggleFavoriteSong extends AlbumEvent {
  final String songId;

  const ToggleFavoriteSong({required this.songId});

  @override
  List<Object?> get props => [songId];
}