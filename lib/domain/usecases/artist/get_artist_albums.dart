import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/repository/album/album.dart';

class GetArtistAlbumsUseCase {
  final AlbumRepository repository;

  GetArtistAlbumsUseCase({required this.repository});

  Future<List<AlbumEntity>> call(String artistId) async {
    print('🔧 GetArtistAlbumsUseCase: Getting albums for artistId: $artistId');
    
    try {
      final albums = await repository.getAlbumsByArtist(artistId);
      print('📊 GetArtistAlbumsUseCase: Successfully retrieved ${albums.length} albums');
      return albums;
    } catch (e) {
      print('💥 GetArtistAlbumsUseCase: Error: $e');
      return [];
    }
  }
}