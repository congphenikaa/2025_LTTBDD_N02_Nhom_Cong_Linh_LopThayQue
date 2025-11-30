import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/album/get_album_details.dart';
import '../../../domain/usecases/album/get_songs_by_album.dart';
import '../../../presentation/song_player/bloc/song_player_cubit.dart';
import '../../../service_locator.dart';
import 'album_state.dart';

class AlbumCubit extends Cubit<AlbumState> {
  final GetAlbumDetailsUseCase _getAlbumDetailsUseCase;
  final GetSongsByAlbumUseCase _getSongsByAlbumUseCase;
  late final SongPlayerCubit _songPlayerCubit;

  AlbumCubit({
    required GetAlbumDetailsUseCase getAlbumDetailsUseCase,
    required GetSongsByAlbumUseCase getSongsByAlbumUseCase,
  }) : _getAlbumDetailsUseCase = getAlbumDetailsUseCase,
       _getSongsByAlbumUseCase = getSongsByAlbumUseCase,
       super(AlbumInitial()) {
    _songPlayerCubit = sl<SongPlayerCubit>();
  }

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
        final selectedSong = currentState.songs[songIndex];
        
        // Check if song has audio URL
        if (selectedSong.audioUrl != null && selectedSong.audioUrl!.isNotEmpty) {
          // Load and play song in audio player
          _songPlayerCubit.loadSong(selectedSong.audioUrl!);
          
          emit(AlbumSongPlaying(
            album: currentState.album,
            songs: currentState.songs,
            currentSongIndex: songIndex,
            isPlaying: true,
          ));
          
          print('🎵 AlbumCubit: Playing song "${selectedSong.title}" - ${selectedSong.audioUrl}');
        } else {
          print('❌ AlbumCubit: Song "${selectedSong.title}" has no audio URL');
          // Could emit an error state or show a snackbar
        }
      }
    }
  }

  void pauseSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      // Pause the actual audio player
      _songPlayerCubit.audioPlayer.pause();
      
      emit(AlbumSongPlaying(
        album: currentState.album,
        songs: currentState.songs,
        currentSongIndex: currentState.currentSongIndex,
        isPlaying: false,
      ));
      
      print('⏸️ AlbumCubit: Song paused');
    }
  }

  void resumeSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      // Resume the actual audio player
      _songPlayerCubit.audioPlayer.play();
      
      emit(AlbumSongPlaying(
        album: currentState.album,
        songs: currentState.songs,
        currentSongIndex: currentState.currentSongIndex,
        isPlaying: true,
      ));
      
      print('▶️ AlbumCubit: Song resumed');
    }
  }

  void nextSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      final nextIndex = currentState.currentSongIndex + 1;
      if (nextIndex < currentState.songs.length) {
        final nextSong = currentState.songs[nextIndex];
        
        // Load and play next song
        if (nextSong.audioUrl != null && nextSong.audioUrl!.isNotEmpty) {
          _songPlayerCubit.loadSong(nextSong.audioUrl!);
          
          emit(AlbumSongPlaying(
            album: currentState.album,
            songs: currentState.songs,
            currentSongIndex: nextIndex,
            isPlaying: true,
          ));
          
          print('⏭️ AlbumCubit: Playing next song "${nextSong.title}"');
        }
      } else {
        print('🔚 AlbumCubit: No more songs in album');
      }
    }
  }

  void previousSong() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      final prevIndex = currentState.currentSongIndex - 1;
      if (prevIndex >= 0) {
        final prevSong = currentState.songs[prevIndex];
        
        // Load and play previous song
        if (prevSong.audioUrl != null && prevSong.audioUrl!.isNotEmpty) {
          _songPlayerCubit.loadSong(prevSong.audioUrl!);
          
          emit(AlbumSongPlaying(
            album: currentState.album,
            songs: currentState.songs,
            currentSongIndex: prevIndex,
            isPlaying: true,
          ));
          
          print('⏮️ AlbumCubit: Playing previous song "${prevSong.title}"');
        }
      } else {
        print('🔚 AlbumCubit: No previous songs in album');
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

  // Shuffle play all songs in album
  void shufflePlay() {
    final currentState = state;
    if (currentState is AlbumLoaded && currentState.songs.isNotEmpty) {
      final shuffledIndex = (currentState.songs.length * 0.5).floor(); // Simple shuffle
      playSong(shuffledIndex);
      print('🔀 AlbumCubit: Shuffle play started');
    }
  }

  // Play all songs from the beginning
  void playAll() {
    final currentState = state;
    if (currentState is AlbumLoaded && currentState.songs.isNotEmpty) {
      playSong(0); // Start from first song
      print('🎵 AlbumCubit: Play all started from beginning');
    }
  }

  // Get current song being played
  String? getCurrentSongUrl() {
    final currentState = state;
    if (currentState is AlbumSongPlaying) {
      final currentSong = currentState.songs[currentState.currentSongIndex];
      return currentSong.audioUrl;
    }
    return null;
  }

  // Check if song player is currently playing
  bool get isAudioPlaying => _songPlayerCubit.audioPlayer.playing;

  @override
  Future<void> close() async {
    // Don't dispose songPlayerCubit here since it's shared
    return super.close();
  }
}