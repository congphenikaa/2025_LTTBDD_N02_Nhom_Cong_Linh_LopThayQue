import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/service_locator.dart';


class IsFavoriteSongUseCase implements Usecase<bool ,String> {
  @override
  Future<bool> call({String ? params}) async {
    return await sl<SongsRepository>().isFavoriteSong(params!);
  }
  
  
  
}