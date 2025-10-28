import 'package:app_nghenhac/data/sources/artist/artist_firebase_service.dart';
import 'package:app_nghenhac/domain/entities/search/artist.dart';
import 'package:app_nghenhac/domain/repository/artist/artist.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistFirebaseService _artistFirebaseService;

  ArtistRepositoryImpl({required ArtistFirebaseService artistFirebaseService}) 
      : _artistFirebaseService = artistFirebaseService {
    print('🔧 ArtistRepositoryImpl constructor called - USING DATA SOURCE');
  }

  @override
  Future<List<ArtistEntity>> getArtists({int limit = 20}) async {
    try {
      print('🔍 [ArtistRepository] Delegating to ArtistFirebaseService with limit: $limit');
      
      final artists = await _artistFirebaseService.getArtists(limit: limit);
      
      print('📊 [ArtistRepository] Received ${artists.length} artists from service');
      return artists;
      
    } catch (e) {
      print('💥 [ArtistRepository] Error fetching artists: $e');
      return [];
    }
  }
}