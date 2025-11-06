import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/repository/album/album.dart';

class GetAlbumDetailsUseCase implements Usecase<AlbumEntity?, String> {
  final AlbumRepository _repository;

  GetAlbumDetailsUseCase({required AlbumRepository repository}) 
      : _repository = repository;

  @override
  Future<AlbumEntity?> call({String? params}) async {
    if (params == null) {
      throw ArgumentError('Album ID is required');
    }
    
    print('🔍 GetAlbumDetailsUseCase: Getting album details for ID: $params');
    
    try {
      // Get album directly by ID from Firebase
      final album = await _repository.getAlbumById(params);
      
      if (album != null) {
        print('✅ GetAlbumDetailsUseCase: Successfully retrieved album: ${album.title}');
      } else {
        print('❌ GetAlbumDetailsUseCase: Album not found with ID: $params');
      }
      
      return album;
    } catch (e) {
      print('💥 GetAlbumDetailsUseCase: Error getting album details: $e');
      return null;
    }
  }
}