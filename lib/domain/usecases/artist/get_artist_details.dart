import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/repository/artist/artist.dart';

class GetArtistDetailsUseCase {
  final ArtistRepository repository;

  GetArtistDetailsUseCase({required this.repository});

  Future<ArtistEntity?> call(String artistId) async {
    print('🔧 GetArtistDetailsUseCase: Getting details for artist: $artistId');
    
    try {
      final artistDetails = await repository.getArtistDetails(artistId);
      print('📊 GetArtistDetailsUseCase: Successfully retrieved artist details');
      return artistDetails;
    } catch (e) {
      print('💥 GetArtistDetailsUseCase: Error: $e');
      return null;
    }
  }
}