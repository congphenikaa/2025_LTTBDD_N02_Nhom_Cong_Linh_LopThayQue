import 'package:dartz/dartz.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';

abstract class SongsRepository {
  Future<Either> getNewsSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong (String songId);
  Future<Either> getUserFavoriteSongs();
  Future<List<SongEntity>> getSongsByArtist(String artistId);
  Future<List<SongEntity>> getSongsByAlbum(String albumId);
  Future<List<SongEntity>> getSongsByPlaylist(String playlistId);
}