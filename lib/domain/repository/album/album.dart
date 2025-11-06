import 'package:app_nghenhac/domain/entities/search/album.dart';

abstract class AlbumRepository {
  Future<List<AlbumEntity>> getAlbums({int limit = 20});
  Future<List<AlbumEntity>> getAlbumsByArtist(String artistId);
  Future<AlbumEntity?> getAlbumById(String albumId);
}