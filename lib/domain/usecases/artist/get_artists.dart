import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/repository/artist/artist.dart';

class GetArtistsUseCase {
  final ArtistRepository repository;

  GetArtistsUseCase({required this.repository});

  Future<List<ArtistEntity>> call({int limit = 20}) async {
    print('🔧 GetArtistsUseCase: Starting with limit: $limit');
    
    try {
      final artists = await repository.getArtists(limit: limit);
      print('📊 GetArtistsUseCase: Successfully retrieved ${artists.length} artists');
      return artists;
    } catch (e) {
      print('💥 GetArtistsUseCase: Error: $e');
      return [];
    }
  }
}