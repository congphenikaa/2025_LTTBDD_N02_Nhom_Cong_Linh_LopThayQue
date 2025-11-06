import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/album/get_album_details.dart';
import '../../../domain/usecases/album/get_songs_by_album.dart';
import 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final GetAlbumDetailsUseCase _getAlbumDetailsUseCase;
  final GetSongsByAlbumUseCase _getSongsByAlbumUseCase;

  AlbumCubit({
    required GetAlbumDetailsUseCase getAlbumDetailsUseCase,
    required GetSongsByAlbumUseCase getSongsByAlbumUseCase,
  }) : _getAlbumDetailsUseCase = getAlbumDetailsUseCase,
       _getSongsByAlbumUseCase = getSongsByAlbumUseCase,
       super(AlbumInitial());

  Future<void> loadAlbumDetails(String albumId) async {
    try {
      emit(AlbumLoading());
      
      print('🔍 AlbumCubit: Loading album details for ID: $albumId');
      
      // Get album details
      final album = await _getAlbumDetailsUseCase.call(params: albumId);
      
      if (album == null) {
        emit(const AlbumLoadFailure(message: 'Album không tìm thấy'));
        return;
      }
      
      // Get songs in the album
      final songs = await _getSongsByAlbumUseCase.call(params: albumId);
      
      print('🎵 AlbumCubit: Loaded album "${album.title}" with ${songs.length} songs');
      
      emit(AlbumLoaded(album: album, songs: songs));
    } catch (e) {
      print('❌ AlbumCubit: Error loading album details: $e');
      emit(AlbumLoadFailure(message: 'Không thể tải thông tin album: ${e.toString()}'));
    }
  }

  void playSong(int songIndex) {
    final currentState = state;
    if (currentState is AlbumLoaded) {
      if (songIndex >= 0 && songIndex < currentState.songs.length) {
        emit(AlbumSongPlaying(
          album: currentState.album,
          songs: currentState.songs,
          currentSongIndex: songIndex,
          isPlaying: true,
        ));
      }
    }
  }

  void pauseSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      emit(AlbumSongPlaying(
        album: currentState.album,
        songs: currentState.songs,
        currentSongIndex: currentState.currentSongIndex,
        isPlaying: false,
      ));
    }
  }

  void resumeSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      emit(AlbumSongPlaying(
        album: currentState.album,
        songs: currentState.songs,
        currentSongIndex: currentState.currentSongIndex,
        isPlaying: true,
      ));
    }
  }

  void nextSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      final nextIndex = currentState.currentSongIndex + 1;
      if (nextIndex < currentState.songs.length) {
        emit(AlbumSongPlaying(
          album: currentState.album,
          songs: currentState.songs,
          currentSongIndex: nextIndex,
          isPlaying: currentState.isPlaying,
        ));
      }
    }
  }

  void previousSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      final prevIndex = currentState.currentSongIndex - 1;
      if (prevIndex >= 0) {
        emit(AlbumSongPlaying(
          album: currentState.album,
          songs: currentState.songs,
          currentSongIndex: prevIndex,
          isPlaying: currentState.isPlaying,
        ));
      }
    }
  }

  void togglePlayPause() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      if (currentState.isPlaying) {
        pauseSong();
      } else {
        resumeSong();
      }
    }
  }
}