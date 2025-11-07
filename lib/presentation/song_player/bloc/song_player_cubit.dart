import 'package:app_nghenhac/presentation/song_player/bloc/song_player_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {

  AudioPlayer audioPlayer = AudioPlayer();

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  bool _isDisposed = false;

  SongPlayerCubit() : super(SongPlayerLoading()){
    _initializeListeners();
  }

  void _initializeListeners() {
    audioPlayer.positionStream.listen((position){
      if (!_isDisposed) {
        songPosition = position;
        updateSongPlayer();
      }
    });

    audioPlayer.durationStream.listen((duration) {
      if (!_isDisposed && duration != null) {
        songDuration = duration;
        updateSongPlayer();
      }
    });

    
    audioPlayer.playerStateStream.listen((playerState) {
      if (!_isDisposed) {
        if (playerState.processingState == ProcessingState.loading) {
          emit(SongPlayerLoading());
        } else if (playerState.processingState == ProcessingState.ready) {
          emit(SongPlayerLoaded());
        }
      }
    });
  }

  void updateSongPlayer() {
    if (!_isDisposed) {
      emit(SongPlayerLoaded());
    }
  }

  Future<void> loadSong(String url) async {
    if (_isDisposed) return;
    
    try {
      emit(SongPlayerLoading());
      await audioPlayer.setUrl(url);
      if (!_isDisposed) {
        emit(SongPlayerLoaded());
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(SongPlayerFailure());
      }
    }
  }

  void playOrPauseSong() {
    if (_isDisposed) return;
    
    if(audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  // Tua tiến 5 giây
  void seekForward5Seconds() {
    if (_isDisposed) return;
    
    final newPosition = songPosition + const Duration(seconds: 5);
    final maxPosition = songDuration;
    
    // Ensure not exceeding song duration
    if (newPosition <= maxPosition) {
      audioPlayer.seek(newPosition);
    } else {
      audioPlayer.seek(maxPosition);
    }
    
    emit(SongPlayerLoaded());
  }

  // Tua lùi 5 giây
  void seekBackward5Seconds() {
    if (_isDisposed) return;
    
    final newPosition = songPosition - const Duration(seconds: 5);
    
    // Đảm bảo không nhỏ hơn 0
    if (newPosition >= Duration.zero) {
      audioPlayer.seek(newPosition);
    } else {
      audioPlayer.seek(Duration.zero);
    }
    
    emit(SongPlayerLoaded());
  }

  // Tua đến vị trí cụ thể (cho slider)
  void seekToPosition(Duration position) {
    if (_isDisposed) return;
    
    audioPlayer.seek(position);
    emit(SongPlayerLoaded());
  }

  // Chuyển bài tiếp theo (placeholder - cần implement với playlist)
  void nextSong() {
    if (_isDisposed) return;
    
    // TODO: Implement logic để chuyển sang bài tiếp theo trong playlist
    print('🎵 Next song requested');
    
    // Tạm thời restart bài hiện tại
    audioPlayer.seek(Duration.zero);
    audioPlayer.play();
    
    emit(SongPlayerLoaded());
  }

  // Chuyển bài trước đó (placeholder - cần implement với playlist)
  void previousSong() {
    if (_isDisposed) return;
    
    // TODO: Implement logic để chuyển sang bài trước đó trong playlist
    print('🎵 Previous song requested');
    
    // Tạm thời restart bài hiện tại
    audioPlayer.seek(Duration.zero);
    audioPlayer.play();
    
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    await audioPlayer.dispose();
    return super.close();
  }
}