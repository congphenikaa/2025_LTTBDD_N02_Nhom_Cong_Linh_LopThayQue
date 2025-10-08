import 'package:app_nghenhac/data/sources/song/song_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class SongRepositoryImpl extends SongsRepository {
  @override
  Future<Either> getNewsSongs() async {
    return await sl<SongFirebaseService>().getNewsSongs();
  }
  


  @override
  Future<Either> getPlayList() async {
    return await sl<SongFirebaseService>().getPlayList();
  }

} 