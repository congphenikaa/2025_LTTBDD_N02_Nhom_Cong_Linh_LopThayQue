import 'package:app_nghenhac/domain/entities/search/song.dart';

abstract class PlaylistDetailState {}

class PlaylistDetailLoading extends PlaylistDetailState {}

class PlaylistDetailLoaded extends PlaylistDetailState {
  final List<SongEntity> songs;
  
  PlaylistDetailLoaded({required this.songs});
}

class PlaylistDetailFailure extends PlaylistDetailState {
  final String message;
  
  PlaylistDetailFailure({required this.message});
}