import 'package:app_nghenhac/domain/entities/song/song.dart';
import 'package:app_nghenhac/domain/usecases/song/get_favorite_songs.dart';
import 'package:app_nghenhac/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteSongsCubit extends Cubit<FavoriteSongsState> {
  FavoriteSongsCubit() : super(FavoriteSongsLoading());


  List<SongEntity> favoriteSongs = [];
  Future<void> getFavoriteSongs() async {

    var result = await sl<GetFavoriteSongsUseCase>().call();

    result.fold(
      (l){
        emit(
          FavoriteSongsFailure()
        );
      },
      (r){
        favoriteSongs = r;
        emit(
          FavoriteSongsLoaded(favoriteSongs: favoriteSongs)
        );
      }

    );

  }
}