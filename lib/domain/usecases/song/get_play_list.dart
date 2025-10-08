import 'package:app_nghenhac/core/usecase/usecase.dart';
import 'package:app_nghenhac/data/repository/song/song_repository_impl.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:dartz/dartz.dart';

class GetPlayListUseCase implements Usecase<Either ,dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<SongRepositoryImpl>().getPlayList();
  }


  
}