import 'package:app_nghenhac/data/sources/album/album_firebase_service.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/repository/album/album.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumFirebaseService _albumFirebaseService;

  AlbumRepositoryImpl({required AlbumFirebaseService albumFirebaseService}) 
      : _albumFirebaseService = albumFirebaseService;

  @override
  Future<List<AlbumEntity>> getAlbums({int limit = 20}) async {
    try {
      print('🔍 AlbumRepository: Calling AlbumFirebaseService to get $limit albums');
      
      final albums = await _albumFirebaseService.getAlbums(limit: limit);
      
      print('📊 AlbumRepository: Received ${albums.length} albums from service');
      print('🏁 AlbumRepository: Successfully loaded ${albums.length} albums');
      return albums;
      
    } catch (e) {
      print('💥 AlbumRepository: Error in getAlbums: $e');
      throw Exception('Failed to load albums: ${e.toString()}');
    }
  }

  @override
  Future<List<AlbumEntity>> getAlbumsByArtist(String artistId) async {
    try {
      print('🔍 AlbumRepository: Calling AlbumFirebaseService to get albums for artistId: $artistId');
      
      final albums = await _albumFirebaseService.getAlbumsByArtist(artistId);
      
      print('📊 AlbumRepository: Received ${albums.length} albums for artist from service');
      return albums;
      
    } catch (e) {
      print('💥 AlbumRepository: Error in getAlbumsByArtist: $e');
      return [];
    }
  }
}