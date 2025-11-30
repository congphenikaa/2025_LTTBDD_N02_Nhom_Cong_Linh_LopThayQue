import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';

class GetSongsByAlbumUseCase implements Usecase<List<SongEntity>, String> {
  final SongsRepository _repository;

  GetSongsByAlbumUseCase({required SongsRepository repository}) 
      : _repository = repository;

  @override
  Future<List<SongEntity>> call({String? params}) async {
    if (params == null) {
      throw ArgumentError('Album ID is required');
    }
    
    print('🔍 GetSongsByAlbumUseCase: Getting songs for album ID: $params');
    
    try {
      final songs = await _repository.getSongsByAlbum(params);
      print('✅ GetSongsByAlbumUseCase: Successfully retrieved ${songs.length} songs for album $params');
      return songs;
    } catch (e) {
      print('❌ GetSongsByAlbumUseCase: Error getting songs for album $params: $e');
      return [];
    }
  }
}