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

    // Lắng nghe trạng thái loading
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

  @override
  Future<void> close() async {
    _isDisposed = true;
    await audioPlayer.dispose();
    return super.close();
  }
}