import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/entities/search/song.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/service_locator.dart';

class GetPlaylistSongsUseCase implements Usecase<List<SongEntity>, String> {
  @override
  Future<List<SongEntity>> call({String? params}) async {
    print('GetPlaylistSongsUseCase: Getting songs for playlistId: $params');
    
    if (params == null) {
      print('GetPlaylistSongsUseCase: playlistId is null');
      return [];
    }
    
    final result = await sl<SongsRepository>().getSongsByPlaylist(params);
    print('GetPlaylistSongsUseCase: Successfully retrieved ${result.length} songs');
    
    return result;
  }
}