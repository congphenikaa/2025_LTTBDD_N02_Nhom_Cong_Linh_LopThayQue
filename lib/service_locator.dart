import 'package:app_nghenhac/data/repository/auth/auth_repository_impl.dart';
import 'package:app_nghenhac/data/repository/song/song_repository_impl.dart';
import 'package:app_nghenhac/data/sources/auth/auth_firebase_service.dart';
import 'package:app_nghenhac/data/sources/song/song_firebase_service.dart';
import 'package:app_nghenhac/domain/repository/auth/auth.dart';
import 'package:app_nghenhac/domain/repository/song/song.dart';
import 'package:app_nghenhac/domain/usecases/auth/get_user.dart';
import 'package:app_nghenhac/domain/usecases/auth/signin.dart';
import 'package:app_nghenhac/domain/usecases/auth/signup.dart';
import 'package:app_nghenhac/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:app_nghenhac/domain/usecases/song/get_favorite_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/get_news_songs.dart';
import 'package:app_nghenhac/domain/usecases/song/get_play_list.dart';
import 'package:app_nghenhac/domain/usecases/song/is_favorite_song.dart';
import 'package:app_nghenhac/presentation/song_player/bloc/song_player_cubit.dart';
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

  sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
    AddOrRemoveFavoriteSongUseCase()
  );

  sl.registerSingleton<IsFavoriteSongUseCase>(
    IsFavoriteSongUseCase()
  );

  sl.registerSingleton<GetUserUseCase>(
    GetUserUseCase()
  );

  sl.registerSingleton<GetFavoriteSongsUseCase>(
    GetFavoriteSongsUseCase()
  );

  sl.registerFactory<SongPlayerCubit>(
    () => SongPlayerCubit()
  );

}