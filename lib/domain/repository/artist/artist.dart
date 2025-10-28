import 'package:app_nghenhac/domain/entities/search/artist.dart';

abstract class ArtistRepository {
  Future<List<ArtistEntity>> getArtists({int limit = 20});
  Future<ArtistEntity?> getArtistDetails(String artistId);
}