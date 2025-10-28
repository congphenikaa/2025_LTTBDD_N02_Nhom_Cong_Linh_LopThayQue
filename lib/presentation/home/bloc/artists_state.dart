import 'package:app_nghenhac/domain/entities/search/artist.dart';

abstract class ArtistsState {}

class ArtistsLoading extends ArtistsState {}

class ArtistsLoaded extends ArtistsState {
  final List<ArtistEntity> artists;

  ArtistsLoaded({required this.artists});
}

class ArtistsLoadFailure extends ArtistsState {
  final String errorMessage;

  ArtistsLoadFailure({required this.errorMessage});
}