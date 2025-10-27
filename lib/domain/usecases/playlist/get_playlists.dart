import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/entities/search/playlist.dart';
import 'package:app_nghenhac/domain/repository/playlist/playlist.dart';

class GetPlaylistsUseCase implements Usecase<List<PlaylistEntity>, int?> {
  final PlaylistRepository _repository;

  GetPlaylistsUseCase({required PlaylistRepository repository}) 
      : _repository = repository;

  @override
  Future<List<PlaylistEntity>> call({int? params}) async {
    final int limit = params ?? 20;
    print('🔍 GetPlaylistsUseCase: Calling repository to get $limit playlists');
    
    return await _repository.getPlaylists(limit: limit);
  }
}