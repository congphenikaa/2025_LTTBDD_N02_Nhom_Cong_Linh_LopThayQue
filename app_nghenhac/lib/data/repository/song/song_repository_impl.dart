import 'package:app_nghenhac/data/sources/song/song_firebase_service.dart';
import 'package:app_nghenhac/data/sources/song/song_search_service.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
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
  
  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    return await sl<SongFirebaseService>().addOrRemoveFavoriteSong(songId);

  }
  
  @override
  Future<bool> isFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().isFavoriteSong(songId);

  }
  
  @override
  Future<Either> getUserFavoriteSongs() async {
  return await sl<SongFirebaseService>().getUserFavoriteSongs();
  }

  @override
  Future<List<SongEntity>> getSongsByArtist(String artistId) async {
    try {
      print('🔍 [SongRepository] Getting songs for artistId: $artistId');
      
      final songSearchService = sl<SongSearchService>();
      final songs = await songSearchService.getSongsByArtist(artistId);
      print('📊 [SongRepository] Received ${songs.length} songs for artist from search service');
      return songs;
      
    } catch (e) {
      print('💥 [SongRepository] Error fetching songs for artist: $e');
      return [];
    }
  }

  @override
  Future<List<SongEntity>> getSongsByAlbum(String albumId) async {
    try {
      print('🔍 [SongRepository] Getting songs for albumId: $albumId');
      
      final songSearchService = sl<SongSearchService>();
      final songs = await songSearchService.getSongsByAlbum(albumId);
      print('📊 [SongRepository] Received ${songs.length} songs for album from search service');
      return songs;
      
    } catch (e) {
      print('💥 [SongRepository] Error fetching songs for album: $e');
      return [];
    }
  }

  @override
  Future<List<SongEntity>> getSongsByPlaylist(String playlistId) async {
    try {
      print('🔍 [SongRepository] Getting songs for playlistId: $playlistId');
      
      final songSearchService = sl<SongSearchService>();
      final songs = await songSearchService.getSongsByPlaylist(playlistId);
      print('📊 [SongRepository] Received ${songs.length} songs for playlist from search service');
      return songs;
      
    } catch (e) {
      print('💥 [SongRepository] Error fetching songs for playlist: $e');
      return [];
    }
  }

} 