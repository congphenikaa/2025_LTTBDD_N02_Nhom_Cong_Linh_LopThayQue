import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_nghenhac/domain/usecases/song/get_playlist_songs.dart';
import 'package:app_nghenhac/presentation/playlist/bloc/playlist_detail_state.dart';
import 'package:app_nghenhac/service_locator.dart';

class PlaylistDetailCubit extends Cubit<PlaylistDetailState> {
  PlaylistDetailCubit() : super(PlaylistDetailLoading());

  Future<void> loadPlaylistSongs(String playlistId) async {
    try {
      print('🎯 PlaylistDetailCubit: Starting to load songs for playlist: $playlistId');
      emit(PlaylistDetailLoading());
      
      final songs = await sl<GetPlaylistSongsUseCase>().call(params: playlistId);
      
      print('📊 PlaylistDetailCubit: Successfully loaded ${songs.length} songs');
      emit(PlaylistDetailLoaded(songs: songs));
      
    } catch (e) {
      print('💥 PlaylistDetailCubit: Error loading playlist songs: $e');
      emit(PlaylistDetailFailure(message: 'Cannot load song list'));
    }
  }
}