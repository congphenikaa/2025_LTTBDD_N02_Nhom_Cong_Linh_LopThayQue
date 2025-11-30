import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/entities/search/album.dart';
import 'package:app_nghenhac/domain/repository/album/album.dart';

class GetAlbumsUseCase implements Usecase<List<AlbumEntity>, int?> {
  final AlbumRepository _repository;

  GetAlbumsUseCase({required AlbumRepository repository}) 
      : _repository = repository;

  @override
  Future<List<AlbumEntity>> call({int? params}) async {
    final int limit = params ?? 20;
    print('🔍 GetAlbumsUseCase: Calling repository to get $limit albums');
    
    return await _repository.getAlbums(limit: limit);
  }
}