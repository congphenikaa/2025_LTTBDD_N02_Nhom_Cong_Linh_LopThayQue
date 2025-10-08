import 'package:app_nghenhac/data/repository/auth/auth_repository_impl.dart';
import 'package:app_nghenhac/data/repository/song/song_repository_impl.dart';
import 'package:app_nghenhac/data/sources/auth/auth_firebase_service.dart';
import 'package:app_nghenhac/data/sources/song/song_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/domain/usecases/auth/signin.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:app_nghenhac/domain/usecases/song/get_news_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/get_play_list.dart';
import 'package:get_it/get_it.dart';


final sl = GetIt.instance;

Future<void> initializeDependencies() async { 

  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
  );

  sl.registerSingleton<SongFirebaseService>(
    SongFirebaseServiceImpl()
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl()
  );

  sl.registerSingleton<SongsRepository>(
    SongRepositoryImpl()
  );

  sl.registerSingleton<SongRepositoryImpl>(  
    SongRepositoryImpl()
  );

  sl.registerSingleton<SignupUseCase>(
    SignupUseCase()
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase()
  );

  sl.registerSingleton<GetNewsSongsUseCase>(
    GetNewsSongsUseCase()
  );

  sl.registerSingleton<GetPlayListUseCase>(
    GetPlayListUseCase()
  );

}