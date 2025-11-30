import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';

class GetArtistSongsUseCase {
  final SongsRepository repository;

  GetArtistSongsUseCase({required this.repository});

  Future<List<SongEntity>> call(String artistId) async {
    print('🔧 GetArtistSongsUseCase: Getting songs for artistId: $artistId');
    
    try {
      final songs = await repository.getSongsByArtist(artistId);
      print('📊 GetArtistSongsUseCase: Successfully retrieved ${songs.length} songs');
      return songs;
    } catch (e) {
      print('💥 GetArtistSongsUseCase: Error: $e');
      return [];
    }
  }
}